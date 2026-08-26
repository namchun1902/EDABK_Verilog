// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vmux2to1__pch.h"

//============================================================
// Constructors

Vmux2to1::Vmux2to1(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vmux2to1__Syms(contextp(), _vcname__, this)}
    , d0{vlSymsp->TOP.d0}
    , d1{vlSymsp->TOP.d1}
    , sel{vlSymsp->TOP.sel}
    , out{vlSymsp->TOP.out}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vmux2to1::Vmux2to1(const char* _vcname__)
    : Vmux2to1(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vmux2to1::~Vmux2to1() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vmux2to1___024root___eval_debug_assertions(Vmux2to1___024root* vlSelf);
#endif  // VL_DEBUG
void Vmux2to1___024root___eval_static(Vmux2to1___024root* vlSelf);
void Vmux2to1___024root___eval_initial(Vmux2to1___024root* vlSelf);
void Vmux2to1___024root___eval_settle(Vmux2to1___024root* vlSelf);
void Vmux2to1___024root___eval(Vmux2to1___024root* vlSelf);

void Vmux2to1::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmux2to1::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vmux2to1___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vmux2to1___024root___eval_static(&(vlSymsp->TOP));
        Vmux2to1___024root___eval_initial(&(vlSymsp->TOP));
        Vmux2to1___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vmux2to1___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vmux2to1::eventsPending() { return false; }

uint64_t Vmux2to1::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vmux2to1::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vmux2to1___024root___eval_final(Vmux2to1___024root* vlSelf);

VL_ATTR_COLD void Vmux2to1::final() {
    Vmux2to1___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vmux2to1::hierName() const { return vlSymsp->name(); }
const char* Vmux2to1::modelName() const { return "Vmux2to1"; }
unsigned Vmux2to1::threads() const { return 1; }
void Vmux2to1::prepareClone() const { contextp()->prepareClone(); }
void Vmux2to1::atClone() const {
    contextp()->threadPoolpOnClone();
}
