// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfull_adder__pch.h"

//============================================================
// Constructors

Vfull_adder::Vfull_adder(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfull_adder__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , ci{vlSymsp->TOP.ci}
    , sum{vlSymsp->TOP.sum}
    , co{vlSymsp->TOP.co}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfull_adder::Vfull_adder(const char* _vcname__)
    : Vfull_adder(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfull_adder::~Vfull_adder() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfull_adder___024root___eval_debug_assertions(Vfull_adder___024root* vlSelf);
#endif  // VL_DEBUG
void Vfull_adder___024root___eval_static(Vfull_adder___024root* vlSelf);
void Vfull_adder___024root___eval_initial(Vfull_adder___024root* vlSelf);
void Vfull_adder___024root___eval_settle(Vfull_adder___024root* vlSelf);
void Vfull_adder___024root___eval(Vfull_adder___024root* vlSelf);

void Vfull_adder::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfull_adder::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfull_adder___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfull_adder___024root___eval_static(&(vlSymsp->TOP));
        Vfull_adder___024root___eval_initial(&(vlSymsp->TOP));
        Vfull_adder___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfull_adder___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfull_adder::eventsPending() { return false; }

uint64_t Vfull_adder::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfull_adder::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfull_adder___024root___eval_final(Vfull_adder___024root* vlSelf);

VL_ATTR_COLD void Vfull_adder::final() {
    Vfull_adder___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfull_adder::hierName() const { return vlSymsp->name(); }
const char* Vfull_adder::modelName() const { return "Vfull_adder"; }
unsigned Vfull_adder::threads() const { return 1; }
void Vfull_adder::prepareClone() const { contextp()->prepareClone(); }
void Vfull_adder::atClone() const {
    contextp()->threadPoolpOnClone();
}
