//
// Created by rowandjj on 2019/4/3.
//

#include "jsc_debugger_impl.h"
#include <thread>

using namespace JSC;
namespace kraken{
    namespace Debugger {
        JSCDebuggerImpl::JSCDebuggerImpl(
                JSGlobalObject* globalObject)
                : Inspector::ScriptDebugServer(globalObject->vm()), m_globalObject(globalObject) {
        }

        void JSCDebuggerImpl::recompileAllJSFunctions() {
            KRAKEN_LOG(VERBOSE) << "recompileAllJSFunctions called";
            JSC::JSLockHolder holder(vm());
            JSC::Debugger::recompileAllJSFunctions();
        }

        void JSCDebuggerImpl::attachDebugger() {
            attach(m_globalObject);
        }

        void JSCDebuggerImpl::detachDebugger(bool isBeingDestroyed) {

            KRAKEN_LOG(VERBOSE) << "[debugger] JS debugger detached!";

            detach(m_globalObject, isBeingDestroyed ? Debugger::GlobalObjectIsDestructing
                                                     : Debugger::TerminatingDebuggingSession);
            if (!isBeingDestroyed)
                recompileAllJSFunctions();
        }

        void JSCDebuggerImpl::runEventLoopWhilePaused() {
            // Drop all locks so another thread can work in the VM while we are nested.
            JSC::JSLock::DropAllLocks dropAllLocks(m_globalObject->vm());

            // 最好是通过信号量等方式阻塞等待，避免空转，不过由于基类相关API是private的，无法复写
            while (!m_doneProcessingDebuggerEvents) {
                std::this_thread::sleep_for(std::chrono::milliseconds(50));
            }
        }
    }
}