// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfull_adder.h for the primary calling header

#ifndef VERILATED_VFULL_ADDER___024ROOT_H_
#define VERILATED_VFULL_ADDER___024ROOT_H_  // guard

#include "verilated.h"


class Vfull_adder__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfull_adder___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(a,0,0);
    VL_IN8(b,0,0);
    VL_IN8(ci,0,0);
    VL_OUT8(sum,0,0);
    VL_OUT8(co,0,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vfull_adder__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfull_adder___024root(Vfull_adder__Syms* symsp, const char* v__name);
    ~Vfull_adder___024root();
    VL_UNCOPYABLE(Vfull_adder___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
