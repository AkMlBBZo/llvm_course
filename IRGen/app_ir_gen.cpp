#include "../sim.h"

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define PIXEL_SIZE 8
#define COLOR_MAX_HEIGH 512
#define MIN_RED 64
#define SIM_X_SIZE 1536//512
#define SIM_Y_SIZE 768//256
#define X_SIZE SIM_X_SIZE / PIXEL_SIZE
#define Y_SIZE SIM_Y_SIZE / PIXEL_SIZE
#define ADDED_HEIGH 64

int main() {
  LLVMContext context;
  // ; ModuleID = 'app.c'
  // source_filename = "app.c"
  Module *module = new Module("app.c", context);
  IRBuilder<> builder(context);

  ////////////////// sim.h //////////////////

  // declare void @simPutPixel(i32, i32, i32)
  // local_unnamed_addr #1
  Type *voidType = Type::getVoidTy(context);
  Type *int32Type = Type::getInt32Ty(context);
  Type *simPutPixelParamTypes[] = {int32Type, int32Type, int32Type};
  FunctionType *simPutPixelType =
      FunctionType::get(voidType, simPutPixelParamTypes, false);
  FunctionCallee simPutPixelFunc =
      module->getOrInsertFunction("simPutPixel", simPutPixelType);

  // declare void @simFlush()
  FunctionType *simFlushType = FunctionType::get(voidType, false);
  FunctionCallee simFlushFunc =
      module->getOrInsertFunction("simFlush", simFlushType);

  // int simHasClick()
  FunctionType *simHasClickType = FunctionType::get(int32Type, false);
  FunctionCallee simHasClickFunc =
      module->getOrInsertFunction("simHasClick", simHasClickType);

  // int simGetClick()
  FunctionType *simGetClickType = FunctionType::get(int32Type, false);
  FunctionCallee simGetClickFunc =
      module->getOrInsertFunction("simGetClick", simGetClickType);

  ////////////////// app.c //////////////////
{ // getX
  Type *getXParamTypes[] = {int32Type};
  FunctionType *getXType = FunctionType::get(int32Type, getXParamTypes, false);
  Function *getXFunc = Function::Create(
    getXType,
    Function::ExternalLinkage,
    "getX",
    module
  );

  auto *pos = getXFunc->getArg(0);
  BasicBlock *entry = BasicBlock::Create(context, "entry", getXFunc);
  builder.SetInsertPoint(entry);
  Value *x = builder.CreateAShr(pos, builder.getInt32(16));
  Value *cellX = builder.CreateSDiv(x, builder.getInt32(PIXEL_SIZE));

  builder.CreateRet(cellX);
}
  
{ // getY
  Type *getYParamTypes[] = {int32Type};
  FunctionType *getYType = FunctionType::get(int32Type, getYParamTypes, false);
  Function *getYFunc = Function::Create(
    getYType,
    Function::ExternalLinkage,
    "getY",
    module
  );

  auto *pos = getYFunc->getArg(0);
  BasicBlock *entry = BasicBlock::Create(context, "entry", getYFunc);
  builder.SetInsertPoint(entry);
  Value *y = builder.CreateAnd(pos, builder.getInt32(0xffff));
  Value *cellY = builder.CreateSDiv(y, builder.getInt32(PIXEL_SIZE));

  builder.CreateRet(cellY);
}
   
{ // calcColor
  Type *ParamTypes[] = {int32Type};
  FunctionType *FuncType = FunctionType::get(int32Type, ParamTypes, false);
  Function *Func = Function::Create(
    FuncType,
    Function::ExternalLinkage,
    "calcColor",
    module
  );

  auto v = Func->getArg(0);

  BasicBlock *entry = BasicBlock::Create(context, "entry", Func);
  BasicBlock *if_end1 = BasicBlock::Create(context, "if_end1", Func);
  BasicBlock *if_end2 = BasicBlock::Create(context, "if_end2", Func);
  BasicBlock *if_end3 = BasicBlock::Create(context, "if_end3", Func);
  BasicBlock *if_end4 = BasicBlock::Create(context, "if_end4", Func);
  BasicBlock *if_end5 = BasicBlock::Create(context, "if_end5", Func);
  BasicBlock *if_1 = BasicBlock::Create(context, "if_1", Func);
  BasicBlock *if_2 = BasicBlock::Create(context, "if_2", Func);
  BasicBlock *if_3 = BasicBlock::Create(context, "if_3", Func);
  BasicBlock *if_4 = BasicBlock::Create(context, "if_4", Func);
  BasicBlock *if_5 = BasicBlock::Create(context, "if_5", Func);
  BasicBlock *ret = BasicBlock::Create(context, "ret", Func);
    
  builder.SetInsertPoint(entry);
  auto v_cmp1 = builder.CreateICmpEQ(v, builder.getInt32(0));
  builder.CreateCondBr(v_cmp1, if_1, if_end1);

  builder.SetInsertPoint(if_end1);
  auto v_cmp2 = builder.CreateICmpEQ(v, builder.getInt32(1));
  builder.CreateCondBr(v_cmp2, if_2, if_end2);

  builder.SetInsertPoint(if_end2);
  auto v_cmp3 = builder.CreateICmpEQ(v, builder.getInt32(2));
  builder.CreateCondBr(v_cmp3, if_3, if_end3);

  builder.SetInsertPoint(if_end3);
  auto v_cmp4 = builder.CreateICmpEQ(v, builder.getInt32(3));
  builder.CreateCondBr(v_cmp4, if_4, if_end4);

  builder.SetInsertPoint(if_end4);
  auto v_cmp5 = builder.CreateICmp(CmpInst::Predicate::ICMP_SGE, v, builder.getInt32(COLOR_MAX_HEIGH));
  builder.CreateCondBr(v_cmp5, if_5, if_end5);
  
  builder.SetInsertPoint(if_5);
  builder.CreateBr(if_end5);

  builder.SetInsertPoint(if_end5);

  PHINode *height = builder.CreatePHI(int32Type, 2, "height");
  height->addIncoming(v, if_end4);
  height->addIncoming(builder.getInt32(COLOR_MAX_HEIGH), if_5);

  // int red = MIN_RED  + ((255 - MIN_RED) * heigh) / COLOR_MAX_HEIGH;
  Value *scaled = builder.CreateMul(builder.getInt32(255 - MIN_RED), height);
  Value *offset = builder.CreateSDiv(scaled, builder.getInt32(COLOR_MAX_HEIGH));
  Value *red = builder.CreateAdd(builder.getInt32(MIN_RED), offset);

  // 0xFF000000 | (red << 16)
  Value *redBits = builder.CreateShl(red, builder.getInt32(16));

  Value *сolor = builder.CreateOr(builder.getInt32(0xFF000000), redBits);

  builder.CreateBr(ret);

  builder.SetInsertPoint(if_1);
  builder.CreateBr(ret);

  builder.SetInsertPoint(if_2);
  builder.CreateBr(ret);

  builder.SetInsertPoint(if_3);
  builder.CreateBr(ret);

  builder.SetInsertPoint(if_4);
  builder.CreateBr(ret);

  builder.SetInsertPoint(ret);

  PHINode *result = builder.CreatePHI(int32Type, 5, "result");
  result->addIncoming(builder.getInt32(0xFF000000), if_1);
  result->addIncoming(builder.getInt32(0xFF00A000), if_2);
  result->addIncoming(builder.getInt32(0xFF800080), if_3);
  result->addIncoming(builder.getInt32(0xFFFFD700), if_4);
  result->addIncoming(сolor, if_end5);

  builder.CreateRet(result);
}  
   
{ // simulate
  Type *ParamTypes[] = {builder.getPtrTy()};
  FunctionType *FuncType = FunctionType::get(builder.getVoidTy(), ParamTypes, false);
  Function *Func = Function::Create(
    FuncType,
    Function::ExternalLinkage,
    "simulate",
    module
  );

  auto v = Func->getArg(0);

  ArrayType *RowType = ArrayType::get(int32Type, Y_SIZE);
  ArrayType *FieldType = ArrayType::get(RowType, X_SIZE);
  ArrayType *DirsType = ArrayType::get(int32Type, 4);

  BasicBlock *entry = BasicBlock::Create(context, "entry", Func);
  BasicBlock *for_cond1 = BasicBlock::Create(context, "for_cond1", Func);
  BasicBlock *for_1 = BasicBlock::Create(context, "for_1", Func);
  BasicBlock *for_inc1 = BasicBlock::Create(context, "for_inc1", Func);
  BasicBlock *for_cond2 = BasicBlock::Create(context, "for_cond2", Func);
  BasicBlock *for_2 = BasicBlock::Create(context, "for_2", Func);
  BasicBlock *for_inc2 = BasicBlock::Create(context, "for_inc2", Func);
  BasicBlock *if_1 = BasicBlock::Create(context, "if_1", Func);
  BasicBlock *for_cond3 = BasicBlock::Create(context, "for_cond3", Func);
  BasicBlock *for_3 = BasicBlock::Create(context, "for_3", Func);
  BasicBlock *if_2 = BasicBlock::Create(context, "if_2", Func);
  BasicBlock *for_inc3 = BasicBlock::Create(context, "for_inc3", Func);
  BasicBlock *for_end3 = BasicBlock::Create(context, "for_end3", Func);
  BasicBlock *for_end1 = BasicBlock::Create(context, "for_end1", Func);
  BasicBlock *for_cond4 = BasicBlock::Create(context, "for_cond4", Func);
  BasicBlock *for_4 = BasicBlock::Create(context, "for_4", Func);
  BasicBlock *for_inc4 = BasicBlock::Create(context, "for_inc4", Func);
  BasicBlock *for_cond5 = BasicBlock::Create(context, "for_cond5", Func);
  BasicBlock *for_5 = BasicBlock::Create(context, "for_5", Func);
  BasicBlock *for_inc5 = BasicBlock::Create(context, "for_inc5", Func);
  BasicBlock *ret = BasicBlock::Create(context, "ret", Func);

  builder.SetInsertPoint(entry);

  // int field_copy[X_SIZE][Y_SIZE] = {0};
  Value *field_copy = builder.CreateAlloca(FieldType);
  builder.CreateMemSet(field_copy, builder.getInt8(0), builder.getInt64(4ULL * (X_SIZE) * (Y_SIZE)), Align(4));

  // const int dirs_x[4] = {-1, 0, 1, 0};
  // const int dirs_y[4] = {0, -1, 0, 1};
  Value *dirs_x = builder.CreateAlloca(DirsType);
  Value *dirs_y = builder.CreateAlloca(DirsType);

  builder.CreateStore(ConstantArray::get(DirsType, {
    builder.getInt32(-1), builder.getInt32(0),
    builder.getInt32(1), builder.getInt32(0)
  }), dirs_x);

  builder.CreateStore(ConstantArray::get(DirsType, {
    builder.getInt32(0), builder.getInt32(-1),
    builder.getInt32(0), builder.getInt32(1)
  }), dirs_y);

  Value *v_x_ptr = builder.CreateAlloca(int32Type);
  Value *v_y_ptr = builder.CreateAlloca(int32Type);
  Value *v_i_ptr = builder.CreateAlloca(int32Type);

  // for (int x = 0; x < X_SIZE; ++x)
  builder.CreateStore(builder.getInt32(0), v_x_ptr);
  builder.CreateBr(for_cond1);

  builder.SetInsertPoint(for_cond1);
  Value *v_x = builder.CreateLoad(int32Type, v_x_ptr);
  builder.CreateCondBr(builder.CreateICmpSLT(v_x, builder.getInt32(X_SIZE)), for_1, for_end1);

  // for (int y = 0; y < Y_SIZE; ++y)
  builder.SetInsertPoint(for_1);
  builder.CreateStore(builder.getInt32(0), v_y_ptr);
  builder.CreateBr(for_cond2);

  builder.SetInsertPoint(for_cond2);
  Value *v_y = builder.CreateLoad(int32Type, v_y_ptr);
  builder.CreateCondBr(builder.CreateICmpSLT(v_y, builder.getInt32(Y_SIZE)), for_2, for_inc1);

  builder.SetInsertPoint(for_2);

  // field_copy[x][y] += field[x][y];
  Value *v_field_ptr = builder.CreateGEP(RowType, v, {v_x, v_y});
  Value *v_copy_ptr = builder.CreateGEP(FieldType, field_copy, {builder.getInt32(0), v_x, v_y});

  Value *v_height = builder.CreateLoad(int32Type, v_field_ptr);
  Value *v_old = builder.CreateLoad(int32Type, v_copy_ptr);
  builder.CreateStore(builder.CreateAdd(v_old, v_height), v_copy_ptr);

  // if (field[x][y] >= 4)
  builder.CreateCondBr(builder.CreateICmpSGE(v_height, builder.getInt32(4)), if_1, for_inc2);

  // for (int i = 0; i < 4; ++i)
  builder.SetInsertPoint(if_1);
  builder.CreateStore(builder.getInt32(0), v_i_ptr);
  builder.CreateBr(for_cond3);

  builder.SetInsertPoint(for_cond3);
  Value *v_i = builder.CreateLoad(int32Type, v_i_ptr);
  builder.CreateCondBr(builder.CreateICmpSLT(v_i, builder.getInt32(4)), for_3, for_end3);

  builder.SetInsertPoint(for_3);

  // int cx = x + dirs_x[i];
  // int cy = y + dirs_y[i];
  Value *v_dx_ptr = builder.CreateGEP(DirsType, dirs_x, {builder.getInt32(0), v_i});
  Value *v_dy_ptr = builder.CreateGEP(DirsType, dirs_y, {builder.getInt32(0), v_i});

  Value *v_cx = builder.CreateAdd(v_x, builder.CreateLoad(int32Type, v_dx_ptr));
  Value *v_cy = builder.CreateAdd(v_y, builder.CreateLoad(int32Type, v_dy_ptr));

  // cx >= 0 && cx < X_SIZE && cy >= 0 && cy < Y_SIZE
  Value *v_cmp1 = builder.CreateAnd(
    builder.CreateICmpSGE(v_cx, builder.getInt32(0)),
    builder.CreateICmpSLT(v_cx, builder.getInt32(X_SIZE))
  );
  Value *v_cmp2 = builder.CreateAnd(
    builder.CreateICmpSGE(v_cy, builder.getInt32(0)),
    builder.CreateICmpSLT(v_cy, builder.getInt32(Y_SIZE))
  );

  builder.CreateCondBr(builder.CreateAnd(v_cmp1, v_cmp2), if_2, for_inc3);

  // ++field_copy[cx][cy];
  builder.SetInsertPoint(if_2);
  Value *v_neighbor_ptr = builder.CreateGEP(FieldType, field_copy, {builder.getInt32(0), v_cx, v_cy});
  Value *v_neighbor = builder.CreateLoad(int32Type, v_neighbor_ptr);

  builder.CreateStore(builder.CreateAdd(v_neighbor, builder.getInt32(1)), v_neighbor_ptr);
  builder.CreateBr(for_inc3);

  builder.SetInsertPoint(for_inc3);
  builder.CreateStore(builder.CreateAdd(v_i, builder.getInt32(1)), v_i_ptr);
  builder.CreateBr(for_cond3);

  // field_copy[x][y] -= 4;
  builder.SetInsertPoint(for_end3);
  Value *v_updated = builder.CreateLoad(int32Type, v_copy_ptr);
  builder.CreateStore(builder.CreateSub(v_updated, builder.getInt32(4)), v_copy_ptr);
  builder.CreateBr(for_inc2);

  builder.SetInsertPoint(for_inc2);
  builder.CreateStore(builder.CreateAdd(v_y, builder.getInt32(1)), v_y_ptr);
  builder.CreateBr(for_cond2);

  builder.SetInsertPoint(for_inc1);
  builder.CreateStore(builder.CreateAdd(v_x, builder.getInt32(1)), v_x_ptr);
  builder.CreateBr(for_cond1);

  // field = field_copy
  builder.SetInsertPoint(for_end1);
  builder.CreateStore(builder.getInt32(0), v_x_ptr);
  builder.CreateBr(for_cond4);

  builder.SetInsertPoint(for_cond4);
  Value *v_x2 = builder.CreateLoad(int32Type, v_x_ptr);
  builder.CreateCondBr(builder.CreateICmpSLT(v_x2, builder.getInt32(X_SIZE)), for_4, ret);

  builder.SetInsertPoint(for_4);
  builder.CreateStore(builder.getInt32(0), v_y_ptr);
  builder.CreateBr(for_cond5);

  builder.SetInsertPoint(for_cond5);
  Value *v_y2 = builder.CreateLoad(int32Type, v_y_ptr);
  builder.CreateCondBr(builder.CreateICmpSLT(v_y2, builder.getInt32(Y_SIZE)), for_5, for_inc4);

  // field[x][y] = field_copy[x][y];
  builder.SetInsertPoint(for_5);
  Value *v_src = builder.CreateGEP(FieldType, field_copy, {builder.getInt32(0), v_x2, v_y2});
  Value *v_dst = builder.CreateGEP(RowType, v, {v_x2, v_y2});
  builder.CreateStore(builder.CreateLoad(int32Type, v_src), v_dst);
  builder.CreateBr(for_inc5);

  builder.SetInsertPoint(for_inc5);
  builder.CreateStore(builder.CreateAdd(v_y2, builder.getInt32(1)), v_y_ptr);
  builder.CreateBr(for_cond5);

  builder.SetInsertPoint(for_inc4);
  builder.CreateStore(builder.CreateAdd(v_x2, builder.getInt32(1)), v_x_ptr);
  builder.CreateBr(for_cond4);

  builder.SetInsertPoint(ret);
  builder.CreateRetVoid();
}

{ // addSand
  Type *ParamTypes[] = {builder.getPtrTy(), int32Type};
  FunctionType *FuncType = FunctionType::get(builder.getVoidTy(), ParamTypes, false);
  Function *Func = Function::Create(
    FuncType,
    Function::ExternalLinkage,
    "addSand",
    module
  );

  auto v = Func->getArg(0);
  auto v2 = Func->getArg(1);

  BasicBlock *entry = BasicBlock::Create(context, "entry", Func);

  builder.SetInsertPoint(entry);

  FunctionType *CoordType = FunctionType::get(int32Type, {int32Type}, false);

  Value *v_pos[] = {v2};

  auto vx = module->getOrInsertFunction("getX", CoordType);
  auto v_call = builder.CreateCall(vx, v_pos);

  auto vy = module->getOrInsertFunction("getY", CoordType);
  auto v_call2 = builder.CreateCall(vy, v_pos);

  // field[px][py].
  ArrayType *RowType = ArrayType::get(int32Type, Y_SIZE);
  Value *v_ptr = builder.CreateGEP(RowType, v, {v_call, v_call2});

  // field[px][py] += ADDED_HEIGH;
  Value *v_old = builder.CreateLoad(int32Type, v_ptr);
  Value *v_new = builder.CreateAdd(v_old, builder.getInt32(ADDED_HEIGH));
  builder.CreateStore(v_new, v_ptr);

  builder.CreateRetVoid();
}  

  ///////////////////////////////////////////

  // define void @app() {
  FunctionType *appFuncType = FunctionType::get(voidType, false);
  Function *appFunc =
      Function::Create(appFuncType, Function::ExternalLinkage, "app", module);

{
  Function *Func = appFunc;
  ArrayType *RowType = ArrayType::get(int32Type, Y_SIZE);
  ArrayType *FieldType = ArrayType::get(RowType, X_SIZE);

  BasicBlock *entry = BasicBlock::Create(context, "entry", Func);
  BasicBlock *while_cond1 = BasicBlock::Create(context, "while_cond1", Func);
  BasicBlock *while_1 = BasicBlock::Create(context, "while_1", Func);
  BasicBlock *while_end1 = BasicBlock::Create(context, "while_end1", Func);
  BasicBlock *for_cond1 = BasicBlock::Create(context, "for_cond1", Func);
  BasicBlock *for_1 = BasicBlock::Create(context, "for_1", Func);
  BasicBlock *for_inc1 = BasicBlock::Create(context, "for_inc1", Func);
  BasicBlock *for_cond2 = BasicBlock::Create(context, "for_cond2", Func);
  BasicBlock *for_2 = BasicBlock::Create(context, "for_2", Func);
  BasicBlock *for_inc2 = BasicBlock::Create(context, "for_inc2", Func);
  BasicBlock *for_end1 = BasicBlock::Create(context, "for_end1", Func);

  builder.SetInsertPoint(entry);

  // int field[X_SIZE][Y_SIZE] = {0};
  Value *field = builder.CreateAlloca(FieldType);
  builder.CreateMemSet(field, builder.getInt8(0), builder.getInt64(4ULL * (X_SIZE) * (Y_SIZE)), Align(4));

  Value *v_x_ptr = builder.CreateAlloca(int32Type);
  Value *v_y_ptr = builder.CreateAlloca(int32Type);

  Value *v_field = builder.CreateGEP(FieldType, field, {builder.getInt32(0), builder.getInt32(0)});
  builder.CreateBr(while_cond1);

  // while (simHasClick())
  builder.SetInsertPoint(while_cond1);
  Value *v_click = builder.CreateCall(simHasClickFunc);
  Value *v_cmp = builder.CreateICmpNE(v_click, builder.getInt32(0));
  builder.CreateCondBr(v_cmp, while_1, while_end1);

  // addSand
  builder.SetInsertPoint(while_1);
  Value *v_pos = builder.CreateCall(simGetClickFunc);
  builder.CreateCall(module->getFunction("addSand"), {v_field, v_pos});
  builder.CreateBr(while_cond1);

  // simulate(field);
  builder.SetInsertPoint(while_end1);
  builder.CreateCall(module->getFunction("simulate"), {v_field});

  // for (int x = 0; x < SIM_X_SIZE; ++x)
  builder.CreateStore(builder.getInt32(0), v_x_ptr);
  builder.CreateBr(for_cond1);

  builder.SetInsertPoint(for_cond1);
  Value *v_x = builder.CreateLoad(int32Type, v_x_ptr);
  builder.CreateCondBr(builder.CreateICmpSLT(v_x, builder.getInt32(SIM_X_SIZE)), for_1, for_end1);

  // for (int y = 0; y < SIM_Y_SIZE; ++y)
  builder.SetInsertPoint(for_1);
  builder.CreateStore(builder.getInt32(0), v_y_ptr);
  builder.CreateBr(for_cond2);

  builder.SetInsertPoint(for_cond2);
  Value *v_y = builder.CreateLoad(int32Type, v_y_ptr);
  builder.CreateCondBr(builder.CreateICmpSLT(v_y, builder.getInt32(SIM_Y_SIZE)), for_2, for_inc1);

  builder.SetInsertPoint(for_2);

  // field[x / PIXEL_SIZE][y / PIXEL_SIZE]
  Value *v_cell_x = builder.CreateSDiv(v_x, builder.getInt32(PIXEL_SIZE));
  Value *v_cell_y = builder.CreateSDiv(v_y, builder.getInt32(PIXEL_SIZE));

  Value *v_ptr = builder.CreateGEP(FieldType, field, {builder.getInt32(0), v_cell_x, v_cell_y});
  Value *v_height = builder.CreateLoad(int32Type, v_ptr);

  // simPutPixel
  Value *v_color = builder.CreateCall(module->getFunction("calcColor"), {v_height});
  builder.CreateCall(simPutPixelFunc, {v_x, v_y, v_color});
  builder.CreateBr(for_inc2);

  // ++y
  builder.SetInsertPoint(for_inc2);
  builder.CreateStore(builder.CreateAdd(v_y, builder.getInt32(1)), v_y_ptr);
  builder.CreateBr(for_cond2);

  // ++x
  builder.SetInsertPoint(for_inc1);
  builder.CreateStore(builder.CreateAdd(v_x, builder.getInt32(1)), v_x_ptr);
  builder.CreateBr(for_cond1);

  // simFlush -> while
  builder.SetInsertPoint(for_end1);
  builder.CreateCall(simFlushFunc);
  builder.CreateBr(while_cond1);
}

  // BasicBlocks:
  // BasicBlock *BB0 = BasicBlock::Create(context, "", appFunc);
  // BasicBlock *BB1 = BasicBlock::Create(context, "", appFunc);
  // BasicBlock *BB3 = BasicBlock::Create(context, "", appFunc);
  // BasicBlock *BB4 = BasicBlock::Create(context, "", appFunc);
  // BasicBlock *BB7 = BasicBlock::Create(context, "", appFunc);
  // BasicBlock *BB10 = BasicBlock::Create(context, "", appFunc);
  // BasicBlock *BB13 = BasicBlock::Create(context, "", appFunc);

  // // 0:
  // builder.SetInsertPoint(BB0);
  // // br label %1
  // builder.CreateBr(BB1);

  // // 3:                                                ; preds = %7
  // builder.SetInsertPoint(BB3);
  // // ret void
  // builder.CreateRetVoid();

  // // 1:                                                ; preds = %0, %7
  // builder.SetInsertPoint(BB1);
  // // %2 = phi i32 [ 0, %0 ], [ %8, %7 ]
  // PHINode *val2 = builder.CreatePHI(int32Type, 2);
  // // br label %4
  // builder.CreateBr(BB4);

  // // 4:                                                ; preds = %1, %10
  // builder.SetInsertPoint(BB4);
  // // %5 = phi i32 [ 0, %1 ], [ %11, %10 ]
  // PHINode *val5 = builder.CreatePHI(int32Type, 2);
  // // %6 = mul nuw nsw i32 %5, %2
  // Value *val6 = builder.CreateMul(val5, val2, "", true, true);
  // // br label %13
  // builder.CreateBr(BB13);

  // // 7:                                                ; preds = %10
  // builder.SetInsertPoint(BB7);
  // // call void @simFlush()
  // builder.CreateCall(simFlushFunc);
  // // %8 = add nuw nsw i32 %2, 1
  // Value *val8 = builder.CreateAdd(val2, builder.getInt32(1), "", true, true);
  // // %9 = icmp eq i32 %8, 1000
  // Value *val9 = builder.CreateICmpEQ(val8, builder.getInt32(1000));
  // // br i1 %9, label %3, label %1, !llvm.loop !5
  // builder.CreateCondBr(val9, BB3, BB1);

  // // 10:                                               ; preds = %13
  // builder.SetInsertPoint(BB10);
  // // %11 = add nuw nsw i32 %5, 1
  // Value *val11 = builder.CreateAdd(val5, builder.getInt32(1), "", true, true);
  // // %12 = icmp eq i32 %11, 256
  // Value *val12 = builder.CreateICmpEQ(val11, builder.getInt32(SIM_Y_SIZE));
  // // br i1 %12, label %7, label %4, !llvm.loop !7
  // builder.CreateCondBr(val12, BB7, BB4);

  // // 13:                                               ; preds = %4, %13
  // builder.SetInsertPoint(BB13);
  // // %14 = phi i32 [ 0, %4 ], [ %17, %13 ]
  // PHINode *val14 = builder.CreatePHI(int32Type, 2);
  // // %15 = mul nuw nsw i32 %6, %14
  // Value *val15 = builder.CreateMul(val6, val14, "", true, true);
  // // %16 = add nsw i32 %15, -16777216
  // Value *val16 = builder.CreateNSWAdd(val15, builder.getInt32(-16777216));
  // // call void @simPutPixel(i32 %14, i32 %5, i32 %16)
  // Value *args[] = {val14, val5, val16};
  // builder.CreateCall(simPutPixelFunc, args);
  // // %17 = add nuw nsw i32 %14, 1
  // Value *val17 = builder.CreateAdd(val14, builder.getInt32(1), "", true, true);
  // // %18 = icmp eq i32 %17, 512
  // Value *val18 = builder.CreateICmpEQ(val17, builder.getInt32(SIM_X_SIZE));
  // // br i1 %18, label %10, label %13, !llvm.loop !8
  // builder.CreateCondBr(val18, BB10, BB13);
  // // }

  // // Link PHI nodes
  // // %2 = phi i32 [ 0, %0 ], [ %8, %7 ]
  // val2->addIncoming(builder.getInt32(0), BB0);
  // val2->addIncoming(val8, BB7);
  // // %5 = phi i32 [ 0, %1 ], [ %11, %10 ]
  // val5->addIncoming(builder.getInt32(0), BB1);
  // val5->addIncoming(val11, BB10);
  // // %14 = phi i32 [ 0, %4 ], [ %17, %13 ]
  // val14->addIncoming(builder.getInt32(0), BB4);
  // val14->addIncoming(val17, BB13);

  // Dump LLVM IR
  module->print(outs(), nullptr);
  outs() << '\n';
  bool verif = verifyModule(*module, &outs());
  outs() << "[VERIFICATION] " << (verif ? "FAIL\n\n" : "OK\n\n");

  // LLVM IR Interpreter
  outs() << "[EE] Run\n";
  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();

  ExecutionEngine *ee = EngineBuilder(std::unique_ptr<Module>(module)).create();
  ee->InstallLazyFunctionCreator([](const std::string &fnName) -> void * {
    if (fnName == "simPutPixel") {
      return reinterpret_cast<void *>(simPutPixel);
    }
    if (fnName == "simFlush") {
      return reinterpret_cast<void *>(simFlush);
    }
    if (fnName == "simHasClick") {
      return reinterpret_cast<void*>(simHasClick);
    }
    if (fnName == "simGetClick") {
      return reinterpret_cast<void*>(simGetClick);
    }
    outs() << "[ExecutionEngine] Can't find function " << fnName
           << ". Catch the Segmentation fault:)\n";
    return nullptr;
  });
  ee->finalizeObject();

  simInit();

  ArrayRef<GenericValue> noargs;
  GenericValue v = ee->runFunction(appFunc, noargs);
  outs() << "[EE] Result: " << v.IntVal << '\n';

  simExit();
  return EXIT_SUCCESS;
}
