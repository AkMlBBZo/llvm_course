#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/Path.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Plugins/PassPlugin.h"
using namespace llvm;

struct IRTrace : public PassInfoMixin<IRTrace> {
    Type *voidType;
    Type *int8PtrTy;
    Type *int32Ty;
    Type *int64Ty;

    bool isFuncLogger(StringRef name) {
        return name == "binOptLogger" || name == "callLogger" ||
            name == "funcStartLogger" || name == "funcEndLogger" ||
            name == "resIntLogger"    || name == "irTraceLogger";
    }

    bool insertCallLog(Module &M, Function &F, IRBuilder<> &builder) {
        Type *params[] = {int8PtrTy, int8PtrTy};
        auto *loggerType = FunctionType::get(voidType, params, false);
        FunctionCallee logger = M.getOrInsertFunction("irTraceLogger", loggerType);

        SmallVector<Instruction *, 128> original;
        for (auto &B : F)
            for (auto &I : B)
                original.push_back(&I);

        bool inserted = false;

        for (Instruction *I : original) {
            
            if (isa<PHINode>(I))
                continue;

            builder.SetInsertPoint(I);

            for (Use &operand : I->operands()) {
                auto *producer = dyn_cast<Instruction>(operand.get());

                if (!producer)
                    continue;

                Value *args[] = {
                    builder.CreateGlobalString(I->getOpcodeName()),
                    builder.CreateGlobalString(producer->getOpcodeName())
                };

                builder.CreateCall(logger, args);
                inserted = true;
            }
        }

        if (inserted) {
            for (auto attr : {
                Attribute::Memory,
                Attribute::NoSync,
                Attribute::NoFree,
                Attribute::Speculatable,
                Attribute::NoUnwind,
                Attribute::WillReturn
            })
            F.removeFnAttr(attr);
        }

        return inserted;
    }

    PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM) {
        StringRef filename = sys::path::filename(M.getSourceFileName());
        
        if (filename != "app.c") {
            return PreservedAnalyses::all();
        }

        outs() << "[Module] " << M.getName() << '\n';

        // Prepare builder for IR modification
        LLVMContext &Ctx = M.getContext();
        IRBuilder<> builder(Ctx);
        voidType = Type::getVoidTy(Ctx);
        int8PtrTy = PointerType::get(Ctx, 0);
        int32Ty = Type::getInt32Ty(Ctx);
        int64Ty = Type::getInt64Ty(Ctx);

        for (auto &F : M) {
            outs() << "[Function] " << F.getName() << " (arg_size: " << F.arg_size() << ")\n";
            if (isFuncLogger(F.getName()) || F.isDeclaration()) {
                continue;
            }

            // if (insertFuncStartLog(M, F, builder)) {
            //     outs() << "insertFuncStartLog done\n";
            // }

            if (insertCallLog(M, F, builder)) {
                outs() << "insertCallLog done\n";
            }
            // if (insertFuncEndLog(M, F, builder)) {
            //     outs() << "insertFuncEndLog done\n";
            // }

            // if (insertBinOptLog(M, F, builder)) {
            //     outs() << "insertBinOptLog done\n";
            // }

            outs() << '\n';
            bool verif = verifyFunction(F, &outs());
            outs() << "[VERIFICATION] " << (verif ? "FAIL\n\n" : "OK\n\n");
        }
        outs() << '\n';
        return PreservedAnalyses::none();
    };
};

PassPluginLibraryInfo getPassPluginInfo() {
  const auto callback = [](PassBuilder &PB) {
    // PB.registerOptimizerLastEPCallback([](ModulePassManager &MPM, auto) {
    // PB.registerPipelineStartEPCallback([](ModulePassManager &MPM, auto) {
    //   MPM.addPass(IRTrace{});
    //   return true;
    // });
    PB.registerOptimizerLastEPCallback(
    [](ModulePassManager &MPM, auto...) {
        MPM.addPass(IRTrace{});
    });

  };

  return {LLVM_PLUGIN_API_VERSION, "MyIRTracePlugin", "0.0.1", callback};
};

/* When a plugin is loaded by the driver, it will call this entry point to
obtain information about this plugin and about how to register its passes.
*/
extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return getPassPluginInfo();
}
