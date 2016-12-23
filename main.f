      program main
      implicit none
#include "lt_types.h"
#include "lt_collier.h"
#include "looptools.h"
        integer i
        ComplexType Acll(Naa), Bcll(Nbb), Ccll(Ncc), Dcll(Ndd), Ecll(Nee)
        ComplexType Alpt(Naa), Blpt(Nbb), Clpt(Ncc), Dlpt(Ndd), Elpt(Nee)
        double precision mu2,delta,lambda
        parameter (mu2=10D0, delta=0D0, lambda=0D0)
        
        ! collier initialization
        call init_collier(5,5)
        call setparam_collier(delta,mu2,lambda) ! delta_uv,mu2,lambda
        call clearcache_cll
        
        ! looptools initialization
        call ltini
        call setlambda(lambda)
        call setuvdiv(0d0)
        call setdelta(delta)
        call setmudim(mu2)
        
        print*
        print*,"epsi_cll = ", getepsi_cll(), ", epsi_lt = ", getepsi()
        print*

        print*,"calling A0i from collier and looptools..."
        call Aput_cll(Acll,(1D0,0D0))
        call Aput(Alpt,(1D0,0D0))
        do i=1,Naa
          print*,Acll(i),Alpt(i)
        enddo
        print*
        
        print*,"calling B0i from collier and looptools..."
        call Bput_cll(Bcll,(1D0,0D0),(2D0,0D0),(3D0,0D0))
        call Bput(Blpt,(1D0,0D0),(2D0,0D0),(3D0,0D0))
        do i=1,Nbb
          print*,Bcll(i),Blpt(i)
        enddo
        print*
        
        print*,"calling C0i from collier and looptools..."
        call Cput_cll(Ccll,(1D0,0D0),(2D0,0D0),(-3D0,0D0),(4D0,0D0),(5D0,0D0),(6D0,0D0))
        call Cput(Clpt,(1D0,0D0),(2D0,0D0),(-3D0,0D0),(4D0,0D0),(5D0,0D0),(6D0,0D0))
        do i=1,Ncc
          print*,Ccll(i),Clpt(i)
        enddo
        print*
        
        print*,"calling D0i from collier and looptools..."
        call Dput_cll(Dcll,(1D0,0D0),(2D0,0D0),(3D0,0D0),(4D0,0D0),(-5D0,0D0),
     &                     (-6D0,0D0),(7D0,0D0),(8D0,0D0),(9D0,0D0),(10D0,0D0))
        call Dput(Dlpt,(1D0,0D0),(2D0,0D0),(3D0,0D0),(4D0,0D0),(-5D0,0D0),
     &                     (-6D0,0D0),(7D0,0D0),(8D0,0D0),(9D0,0D0),(10D0,0D0))
        do i=1,Ndd
          print*,Dcll(i),Dlpt(i)
        enddo
        print*
        
        print*,"calling E0i from collier and looptools..."
        call Eput_cll(Ecll,(1D0,0D0),(2D0,0D0),(3D0,0D0),(4D0,0D0),(5D0,0D0),
     &                     (-6D0,0D0),(-7D0,0D0),(-8D0,0D0),(-9D0,0D0),(-10D0,0D0),
     &                     (11D0,0D0),(12D0,0D0),(13D0,0D0),(14D0,0D0),(15D0,0D0))
        call Eput(Elpt,(1D0,0D0),(2D0,0D0),(3D0,0D0),(4D0,0D0),(5D0,0D0),
     &                     (-6D0,0D0),(-7D0,0D0),(-8D0,0D0),(-9D0,0D0),(-10D0,0D0),
     &                     (11D0,0D0),(12D0,0D0),(13D0,0D0),(14D0,0D0),(15D0,0D0))
        do i=1,Nee
          print*,Ecll(i),Elpt(i)
        enddo
        print*
        
      end
