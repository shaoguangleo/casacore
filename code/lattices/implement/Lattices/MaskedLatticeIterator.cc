//# MaskedLatticeIterator.cc: defines the RO_MaskedLatticeIterator class
//# Copyright (C) 2003
//# Associated Universities, Inc. Washington DC, USA.
//#
//# This library is free software; you can redistribute it and/or modify it
//# under the terms of the GNU Library General Public License as published by
//# the Free Software Foundation; either version 2 of the License, or (at your
//# option) any later version.
//#
//# This library is distributed in the hope that it will be useful, but WITHOUT
//# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
//# License for more details.
//#
//# You should have received a copy of the GNU Library General Public License
//# along with this library; if not, write to the Free Software Foundation,
//# Inc., 675 Massachusetts Ave, Cambridge, MA 02139, USA.
//#
//# Correspondence concerning AIPS++ should be addressed as follows:
//#        Internet email: aips2-request@nrao.edu.
//#        Postal address: AIPS++ Project Office
//#                        National Radio Astronomy Observatory
//#                        520 Edgemont Road
//#                        Charlottesville, VA 22903-2475 USA
//#
//# $Id$

#include <aips/aips.h>

#include <trial/Lattices/MaskedLatticeIterator.h>
#include <aips/Arrays/Array.h>
#include <aips/Arrays/IPosition.h>
#include <aips/Utilities/Assert.h> 
#include <aips/Exceptions/Error.h>


template <class T>
RO_MaskedLatticeIterator<T>::RO_MaskedLatticeIterator()
: itsMaskLattPtr (0)
{}

template <class T>
RO_MaskedLatticeIterator<T>::RO_MaskedLatticeIterator
                                          (const MaskedLattice<T>& mlattice,
					   Bool useRef)
: RO_LatticeIterator<T> (mlattice, useRef)
{
  Lattice<T>* lptr = &(RO_LatticeIterator<T>::lattice());
  itsMaskLattPtr = dynamic_cast<MaskedLattice<T>*>(lptr);
  AlwaysAssert (itsMaskLattPtr, AipsError);
}

template <class T>
RO_MaskedLatticeIterator<T>::RO_MaskedLatticeIterator
                                          (const MaskedLattice<T>& mlattice,
					   const LatticeNavigator& method,
					   Bool useRef)
: RO_LatticeIterator<T> (mlattice, method, useRef)
{
  Lattice<T>* lptr = &(RO_LatticeIterator<T>::lattice());
  itsMaskLattPtr = dynamic_cast<MaskedLattice<T>*>(lptr);
  AlwaysAssert (itsMaskLattPtr, AipsError);
}

template <class T>
RO_MaskedLatticeIterator<T>::RO_MaskedLatticeIterator
                                          (const MaskedLattice<T>& mlattice,
					   const IPosition& cursorShape,
					   Bool useRef)
: RO_LatticeIterator<T> (mlattice, cursorShape, useRef)
{
  Lattice<T>* lptr = &(RO_LatticeIterator<T>::lattice());
  itsMaskLattPtr = dynamic_cast<MaskedLattice<T>*>(lptr);
  AlwaysAssert (itsMaskLattPtr, AipsError);
}

template <class T>
RO_MaskedLatticeIterator<T>::RO_MaskedLatticeIterator
                                 (const RO_MaskedLatticeIterator<T>& other)
: RO_LatticeIterator<T> (other),
  itsMaskLattPtr (0)
{
  if (!isNull()) {
    Lattice<T>* lptr = &(RO_LatticeIterator<T>::lattice());
    itsMaskLattPtr = dynamic_cast<MaskedLattice<T>*>(lptr);
    AlwaysAssert (itsMaskLattPtr, AipsError);
  }
}

template <class T>
RO_MaskedLatticeIterator<T>::RO_MaskedLatticeIterator
                                 (const RO_LatticeIterator<T>& other)
: RO_LatticeIterator<T> (other),
  itsMaskLattPtr (0)
{
  if (!isNull()) {
    Lattice<T>* lptr = &(RO_LatticeIterator<T>::lattice());
    itsMaskLattPtr = dynamic_cast<MaskedLattice<T>*>(lptr);
    AlwaysAssert (itsMaskLattPtr, AipsError);
  }
}

template <class T>
RO_MaskedLatticeIterator<T>::~RO_MaskedLatticeIterator()
{}

template <class T>
RO_MaskedLatticeIterator<T>& RO_MaskedLatticeIterator<T>::operator=
                                 (const RO_MaskedLatticeIterator<T>& other)
{
  if (this != &other) {
    RO_LatticeIterator<T>::operator= (other);
    itsMaskLattPtr = 0;
    if (!isNull()) {
      Lattice<T>* lptr = &(RO_LatticeIterator<T>::lattice());
      itsMaskLattPtr = dynamic_cast<MaskedLattice<T>*>(lptr);
      AlwaysAssert (itsMaskLattPtr, AipsError);
    }
  }
  return *this;
}

template <class T>
RO_MaskedLatticeIterator<T> RO_MaskedLatticeIterator<T>::copy() const
{
  if (isNull()) {
    return RO_MaskedLatticeIterator<T>();
  }
  return RO_MaskedLatticeIterator<T>(RO_LatticeIterator<T>::copy());
}

template <class T>
Array<Bool> RO_MaskedLatticeIterator<T>::getMask
                                         (Bool removeDegenerateAxes) const
{
  return itsMaskLattPtr->getMaskSlice (Slicer(position(),
					      endPosition(),
					      Slicer::endIsLast),
				       removeDegenerateAxes);
}

template <class T>
Bool RO_MaskedLatticeIterator<T>::getMask (COWPtr<Array<Bool> >& arr,
					   Bool removeDegenerateAxes) const
{
  return itsMaskLattPtr->getMaskSlice (arr, position(), cursorShape(),
				       removeDegenerateAxes);
}

template <class T>
Bool RO_MaskedLatticeIterator<T>::getMask (Array<Bool>& arr,
					   Bool removeDegenerateAxes) const
{
  return itsMaskLattPtr->getMaskSlice (arr, position(), cursorShape(),
				       removeDegenerateAxes);
}