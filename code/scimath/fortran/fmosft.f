*=======================================================================
*     Copyright (C) 1999,2001,2002
*     Associated Universities, Inc. Washington DC, USA.
*
*     This library is free software; you can redistribute it and/or
*     modify it under the terms of the GNU Library General Public
*     License as published by the Free Software Foundation; either
*     version 2 of the License, or (at your option) any later version.
*
*     This library is distributed in the hope that it will be useful,
*     but WITHOUT ANY WARRANTY; without even the implied warranty of
*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*     GNU Library General Public License for more details.
*
*     You should have received a copy of the GNU Library General Public
*     License along with this library; if not, write to the Free
*     Software Foundation, Inc., 675 Massachusetts Ave, Cambridge,
*     MA 02139, USA.
*
*     Correspondence concerning AIPS++ should be addressed as follows:
*            Internet email: aips2-request@nrao.edu.
*            Postal address: AIPS++ Project Office
*                            National Radio Astronomy Observatory
*                            520 Edgemont Road
*                            Charlottesville, VA 22903-2475 USA
*
*     $Id$
*-----------------------------------------------------------------------
C
C Grid a number of visibility records
C
      subroutine gmosft (uvw, dphase, xypos, values, nvispol, nvischan,
     $     dopsf, flag, rflag, weight, nrow, rownum,
     $     scale, offset, grid, nx, ny, npol, nchan, freq, c,
     $     support, convsize, sampling, wconvsize, convFunc, 
     $     chanmap, polmap,
     $     sumwt)

      implicit none
      integer nx, ny, npol, nchan, nvispol, nvischan, nrow
      complex values(nvispol, nvischan, nrow)
      complex grid(nx, ny, npol, nchan)
      double precision uvw(3, nrow), freq(nvischan), c, scale(3),
     $     offset(3)
      double precision dphase(nrow), uvdist, xypos(2,nrow)
      complex phasor
      integer flag(nvispol, nvischan, nrow)
      integer rflag(nrow)
      real weight(nvischan, nrow), phase
      double precision sumwt(npol, nchan)
      integer rownum
      integer support(*), rsupport
      integer chanmap(nchan), polmap(npol)
      integer dopsf

      complex nvalue

      integer convsize, sampling, wconvsize
      complex convFunc(convsize, convsize, wconvsize), cwt

      complex shiftx(-convsize:convsize), shifty(-convsize:convsize)

      real norm
      real wt

      logical omosft, doshift

      real pos(3)
      integer loc(3), off(3), iloc(3)
      integer rbeg, rend
      integer ix, iy, ipol, ichan
      integer apol, achan, irow
      double precision pi
      data pi/3.14159265358979323846/
      
      irow=rownum

      rsupport=support(wconvsize)
      do ix=-rsupport,rsupport
         shiftx(ix)=1.0
         shifty(ix)=1.0
      end do
      doshift=.FALSE.

      if(irow.ge.0) then
         rbeg=irow+1
         rend=irow+1
      else 
         rbeg=1
         rend=nrow
      end if

      if((xypos(1,1).ne.0.0).and.(xypos(2,1).ne.0.0)) then
         doshift=.TRUE.
         rsupport=support(wconvsize)
         do ix=-rsupport,rsupport
            phase=-2.0D0*pi*xypos(1,1)*ix/nx
            shiftx(ix)=cmplx(cos(phase), sin(phase))
         end do
         do iy=-rsupport,rsupport
            phase=-2.0D0*pi*xypos(2,1)*iy/ny
            shifty(iy)=cmplx(cos(phase), sin(phase))
         end do
      end if
      do irow=rbeg, rend
         if(rflag(irow).eq.0) then 
         do ichan=1, nvischan
            achan=chanmap(ichan)+1
            if((achan.ge.1).and.(achan.le.nchan).and.
     $           (weight(ichan,irow).gt.0.0)) then
               call smosft(uvw(1,irow), dphase(irow), freq(ichan), c, 
     $              scale, offset, sampling, pos, loc, off, phasor)
               iloc(3)=1+abs(loc(3))
               rsupport=support(iloc(3))
               if (omosft(nx, ny, loc, rsupport)) then
                  do ipol=1, nvispol
                     apol=polmap(ipol)+1
                     if((flag(ipol,ichan,irow).ne.1).and.
     $                    (apol.ge.1).and.(apol.le.npol)) then
C If we are making a PSF then we don't want to phase
C rotate but we do want to reproject uvw
                        if(dopsf.eq.1) then
                           nvalue=cmplx(weight(ichan,irow))
                        else
                           nvalue=weight(ichan,irow)*
     $                          (values(ipol,ichan,irow)*phasor)
                        end if
C norm will be the value we would get for the peak
C at the phase center. We will want to normalize 
C the final image by this term.
                        norm=0.0
                        do iy=-rsupport,rsupport
                           iloc(2)=convsize/2+1+iy*sampling
     $                          +off(2)
                           if(uvw(3,irow).lt.0.0) then
                              do ix=-rsupport,rsupport
                                 iloc(1)=convsize/2+1+ix*sampling
     $                                +off(1)
                                 cwt=conjg(convFunc(iloc(1),
     $                                iloc(2),
     $                                iloc(3)))
                                 if(doshift) then
                                    cwt=cwt*shiftx(ix)*shifty(iy)
                                 end if
                                 grid(loc(1)+ix,
     $                                loc(2)+iy,apol,achan)=
     $                                grid(loc(1)+ix,
     $                                loc(2)+iy,apol,achan)+
     $                                nvalue*cwt
                                 norm=norm+real(cwt)
                              end do
                           else
                              do ix=-rsupport,rsupport
                                 iloc(1)=convsize/2+1+ix*sampling
     $                                +off(1)
                                 cwt=convFunc(iloc(1), iloc(2),
     $                                iloc(3))
                                 if(doshift) then
                                    cwt=cwt*shiftx(ix)*shifty(iy)
                                 end if
                                 grid(loc(1)+ix,
     $                                loc(2)+iy,apol,achan)=
     $                                grid(loc(1)+ix,
     $                                loc(2)+iy,apol,achan)+
     $                                nvalue*cwt
                                 norm=norm+real(cwt)
                              end do
                           end if
                        end do
                        sumwt(apol,achan)=sumwt(apol,achan)+
     $                       weight(ichan,irow)*norm
                     end if
                  end do
               end if
            end if
         end do
         end if
      end do
      return
      end
C
C Degrid a number of visibility records
C
      subroutine dmosft (uvw, dphase, xypos, values, nvispol, nvischan,
     $     flag, rflag,
     $     nrow, rownum, scale, offset, grid, nx, ny, npol, nchan, freq,
     $     c, support, convsize, sampling, wconvsize, convFunc,
     $     chanmap, polmap)

      implicit none
      integer nx, ny, npol, nchan, nvispol, nvischan, nrow
      complex values(nvispol, nvischan, nrow)
      complex grid(nx, ny, npol, nchan)
      double precision uvw(3, nrow), freq(nvischan), c, scale(3),
     $     offset(3)
      double precision dphase(nrow), uvdist, xypos(2,nrow)
      complex phasor
      integer flag(nvispol, nvischan, nrow)
      integer rflag(nrow)
      integer rownum
      integer support(*), rsupport
      integer chanmap(*), polmap(*)

      complex nvalue

      integer convsize, wconvsize, sampling
      complex convFunc(convsize, convsize, wconvsize), cwt

      complex shiftx(-convsize:convsize), shifty(-convsize:convsize)

      real norm, phase

      logical omosft, doshift

      real pos(3)
      integer loc(3), off(3), iloc(3)
      integer rbeg, rend
      integer ix, iy, ipol, ichan
      integer apol, achan, irow
      real wt, wtx, wty
      double precision pi
      data pi/3.14159265358979323846/

      irow=rownum

      rsupport=support(wconvsize)
      do ix=-rsupport,rsupport
         shiftx(ix)=1.0
         shifty(ix)=1.0
      end do
      doshift=.FALSE.

      if(irow.ge.0) then
         rbeg=irow+1
         rend=irow+1
      else 
         rbeg=1
         rend=nrow
      end if
C

      if((xypos(1,1).ne.0.0).and.(xypos(2,1).ne.0.0)) then
         doshift=.TRUE.
         rsupport=support(wconvsize)
         do ix=-rsupport,rsupport
            phase=-2.0D0*pi*xypos(1,1)*ix/nx
            shiftx(ix)=cmplx(cos(phase), sin(phase))
         end do
         do iy=-rsupport,rsupport
            phase=-2.0D0*pi*xypos(2,1)*iy/ny
            shifty(iy)=cmplx(cos(phase), sin(phase))
         end do
      end if
      do irow=rbeg, rend
         if(rflag(irow).eq.0) then
         do ichan=1, nvischan
            achan=chanmap(ichan)+1
            if((achan.ge.1).and.(achan.le.nchan)) then
               call smosft(uvw(1,irow), dphase(irow), freq(ichan), c,
     $              scale, offset, sampling, pos, loc, off, phasor)
               iloc(3)=1+abs(loc(3))
               rsupport=support(iloc(3))
               if (omosft(nx, ny, loc, rsupport)) then
                  do ipol=1, nvispol
                     apol=polmap(ipol)+1
                     if((flag(ipol,ichan,irow).ne.1).and.
     $                    (apol.ge.1).and.(apol.le.npol)) then

                        nvalue=0.0
                        do iy=-rsupport,rsupport
                           iloc(2)=convsize/2+1+sampling*iy+off(2)
                           do ix=-rsupport,rsupport
                              iloc(1)=convsize/2+1+sampling*ix
     $                             +off(1)
                              if(uvw(3,irow).lt.0.0) then
                                 cwt=conjg(convFunc(iloc(1), iloc(2),
     $                                iloc(3)))
                              else 
                                 cwt=convFunc(iloc(1), iloc(2),
     $                                iloc(3))
                              end if
                              if(doshift) then
                                 cwt=cwt*shiftx(ix)*shifty(iy)
                              end if
                              nvalue=nvalue+conjg(cwt)*
     $                             grid(loc(1)+ix,loc(2)+iy,apol,achan)
                           end do
                        end do
                        values(ipol,ichan,irow)=nvalue*conjg(phasor)
                     end if
                  end do
               end if
            end if
         end do
         end if
      end do
      return
      end
C
C Calculate gridded coordinates and the phasor needed for
C phase rotation.
C
      subroutine smosft (uvw, dphase, freq, c, scale, offset, 
     $     sampling, pos, loc, off, phasor)
      implicit none
      integer loc(3), off(3), sampling
      double precision uvw(3), freq, c, scale(3), offset(3)
      real pos(3)
      double precision dphase, phase
      complex phasor
      integer idim
      double precision pi
      data pi/3.14159265358979323846/

      do idim=1,2
         pos(idim)=scale(idim)*uvw(idim)*freq/c+(offset(idim)+1.0)
         loc(idim)=nint(pos(idim))
         off(idim)=nint((loc(idim)-pos(idim))*sampling)
      end do
      pos(3)=abs(scale(3)*uvw(3)*freq/c)
      loc(3)=nint(pos(3))
      off(3)=0

      phase=-2.0D0*pi*dphase*freq/c
      phasor=cmplx(cos(phase), sin(phase))
      return 
      end
      logical function omosft (nx, ny, loc, support)
      implicit none
      integer nx, ny, loc(3), support
      omosft=(loc(1)-support.ge.1).and.(loc(1)+support.le.nx).and.
     $        (loc(2)-support.ge.1).and.(loc(2)+support.le.ny)
      return
      end
