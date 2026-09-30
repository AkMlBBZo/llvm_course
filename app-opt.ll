; ModuleID = 'app.c'
source_filename = "app.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@field = dso_local local_unnamed_addr global [384 x [192 x i32]] zeroinitializer, align 16
@field_copy = dso_local local_unnamed_addr global [384 x [192 x i32]] zeroinitializer, align 16
@dirs_x = dso_local local_unnamed_addr constant [4 x i32] [i32 -1, i32 0, i32 1, i32 0], align 16
@dirs_y = dso_local local_unnamed_addr constant [4 x i32] [i32 0, i32 -1, i32 0, i32 1], align 16
@switch.table.app = private unnamed_addr constant [4 x i32] [i32 -16777216, i32 -16736256, i32 -8388480, i32 -10496], align 4

; Function Attrs: mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(none) uwtable
define dso_local range(i32 -8192, 8192) i32 @getX(i32 noundef %0) local_unnamed_addr #0 {
  %2 = lshr i32 %0, 16
  %3 = trunc nuw i32 %2 to i16
  %4 = sdiv i16 %3, 4
  %5 = sext i16 %4 to i32
  ret i32 %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(none) uwtable
define dso_local noundef range(i32 0, 16384) i32 @getY(i32 noundef %0) local_unnamed_addr #0 {
  %2 = lshr i32 %0, 2
  %3 = and i32 %2, 16383
  ret i32 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(none) uwtable
define dso_local range(i32 -16777216, 0) i32 @calcColor(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp ult i32 %0, 4
  br i1 %2, label %10, label %3

3:                                                ; preds = %1
  %4 = tail call i32 @llvm.smin.i32(i32 %0, i32 512)
  %5 = mul nsw i32 %4, 191
  %6 = sdiv i32 %5, 512
  %7 = shl i32 %6, 16
  %8 = add i32 %7, 4194304
  %9 = or i32 %8, -16777216
  br label %14

10:                                               ; preds = %1
  %11 = zext nneg i32 %0 to i64
  %12 = getelementptr inbounds nuw i32, ptr @switch.table.app, i64 %11
  %13 = load i32, ptr %12, align 4
  br label %14

14:                                               ; preds = %10, %3
  %15 = phi i32 [ %9, %3 ], [ %13, %10 ]
  ret i32 %15
}

; Function Attrs: nofree norecurse nosync nounwind sspstrong memory(readwrite, argmem: none, inaccessiblemem: none, target_mem0: none, target_mem1: none) uwtable
define dso_local void @simulate() local_unnamed_addr #1 {
  br label %1

1:                                                ; preds = %0, %34
  %2 = phi i64 [ 0, %0 ], [ %35, %34 ]
  %3 = getelementptr inbounds nuw [192 x i32], ptr @field, i64 %2
  %4 = getelementptr inbounds nuw [192 x i32], ptr @field_copy, i64 %2
  %5 = add nsw i64 %2, -1
  %6 = icmp ult i64 %5, 384
  %7 = getelementptr inbounds nuw [192 x i32], ptr @field_copy, i64 %5
  %8 = icmp samesign ult i64 %2, 383
  %9 = getelementptr inbounds nuw [192 x i32], ptr @field_copy, i64 %2
  %10 = getelementptr inbounds nuw i8, ptr %9, i64 768
  br label %37

11:                                               ; preds = %73
  %12 = getelementptr inbounds nuw i32, ptr %3, i64 %74
  %13 = load i32, ptr %12, align 4, !tbaa !5
  %14 = getelementptr inbounds nuw i32, ptr %4, i64 %74
  %15 = load i32, ptr %14, align 4, !tbaa !5
  %16 = add nsw i32 %15, %13
  store i32 %16, ptr %14, align 4, !tbaa !5
  %17 = icmp sgt i32 %13, 3
  br i1 %17, label %18, label %34

18:                                               ; preds = %11
  br i1 %6, label %19, label %23

19:                                               ; preds = %18
  %20 = getelementptr inbounds nuw i32, ptr %7, i64 %74
  %21 = load i32, ptr %20, align 4, !tbaa !5
  %22 = add nsw i32 %21, 1
  store i32 %22, ptr %20, align 4, !tbaa !5
  br label %23

23:                                               ; preds = %18, %19
  %24 = getelementptr i32, ptr %4, i64 %74
  %25 = getelementptr i8, ptr %24, i64 -4
  %26 = load i32, ptr %25, align 8, !tbaa !5
  %27 = add nsw i32 %26, 1
  store i32 %27, ptr %25, align 8, !tbaa !5
  br i1 %8, label %28, label %32

28:                                               ; preds = %23
  %29 = getelementptr inbounds nuw i32, ptr %10, i64 %74
  %30 = load i32, ptr %29, align 4, !tbaa !5
  %31 = add nsw i32 %30, 1
  store i32 %31, ptr %29, align 4, !tbaa !5
  br label %32

32:                                               ; preds = %23, %28
  %33 = add nsw i32 %16, -4
  store i32 %33, ptr %14, align 4, !tbaa !5
  br label %34

34:                                               ; preds = %32, %11
  %35 = add nuw nsw i64 %2, 1
  %36 = icmp eq i64 %35, 384
  br i1 %36, label %76, label %1, !llvm.loop !9

37:                                               ; preds = %1, %73
  %38 = phi i64 [ 0, %1 ], [ %74, %73 ]
  %39 = getelementptr inbounds nuw i32, ptr %3, i64 %38
  %40 = load i32, ptr %39, align 4, !tbaa !5
  %41 = getelementptr inbounds nuw i32, ptr %4, i64 %38
  %42 = load i32, ptr %41, align 4, !tbaa !5
  %43 = add nsw i32 %42, %40
  store i32 %43, ptr %41, align 4, !tbaa !5
  %44 = icmp sgt i32 %40, 3
  br i1 %44, label %47, label %45

45:                                               ; preds = %37
  %46 = add nuw nsw i64 %38, 1
  br label %73

47:                                               ; preds = %37
  br i1 %6, label %48, label %52

48:                                               ; preds = %47
  %49 = getelementptr inbounds nuw i32, ptr %7, i64 %38
  %50 = load i32, ptr %49, align 4, !tbaa !5
  %51 = add nsw i32 %50, 1
  store i32 %51, ptr %49, align 4, !tbaa !5
  br label %52

52:                                               ; preds = %48, %47
  %53 = add nsw i64 %38, -1
  %54 = icmp ult i64 %53, 192
  br i1 %54, label %55, label %59

55:                                               ; preds = %52
  %56 = getelementptr inbounds nuw i32, ptr %4, i64 %53
  %57 = load i32, ptr %56, align 4, !tbaa !5
  %58 = add nsw i32 %57, 1
  store i32 %58, ptr %56, align 4, !tbaa !5
  br label %59

59:                                               ; preds = %55, %52
  br i1 %8, label %60, label %64

60:                                               ; preds = %59
  %61 = getelementptr inbounds nuw i32, ptr %10, i64 %38
  %62 = load i32, ptr %61, align 4, !tbaa !5
  %63 = add nsw i32 %62, 1
  store i32 %63, ptr %61, align 4, !tbaa !5
  br label %64

64:                                               ; preds = %60, %59
  %65 = add nuw nsw i64 %38, 1
  %66 = icmp ult i64 %38, 191
  br i1 %66, label %67, label %71

67:                                               ; preds = %64
  %68 = getelementptr inbounds nuw i32, ptr %4, i64 %65
  %69 = load i32, ptr %68, align 4, !tbaa !5
  %70 = add nsw i32 %69, 1
  store i32 %70, ptr %68, align 4, !tbaa !5
  br label %71

71:                                               ; preds = %67, %64
  %72 = add nsw i32 %43, -4
  store i32 %72, ptr %41, align 4, !tbaa !5
  br label %73

73:                                               ; preds = %45, %71
  %74 = phi i64 [ %46, %45 ], [ %65, %71 ]
  %75 = icmp eq i64 %74, 191
  br i1 %75, label %11, label %37, !llvm.loop !11

76:                                               ; preds = %34, %98
  %77 = phi i64 [ %99, %98 ], [ 0, %34 ]
  %78 = getelementptr inbounds nuw [192 x i32], ptr @field_copy, i64 %77
  %79 = getelementptr inbounds nuw [192 x i32], ptr @field, i64 %77
  br label %80

80:                                               ; preds = %80, %76
  %81 = phi i64 [ 0, %76 ], [ %95, %80 ]
  %82 = getelementptr inbounds nuw i32, ptr %78, i64 %81
  %83 = getelementptr inbounds nuw i8, ptr %82, i64 16
  %84 = load <4 x i32>, ptr %82, align 16, !tbaa !5
  %85 = load <4 x i32>, ptr %83, align 16, !tbaa !5
  %86 = getelementptr inbounds nuw i32, ptr %79, i64 %81
  %87 = getelementptr inbounds nuw i8, ptr %86, i64 16
  store <4 x i32> %84, ptr %86, align 16, !tbaa !5
  store <4 x i32> %85, ptr %87, align 16, !tbaa !5
  store <4 x i32> zeroinitializer, ptr %82, align 16, !tbaa !5
  store <4 x i32> zeroinitializer, ptr %83, align 16, !tbaa !5
  %88 = or disjoint i64 %81, 8
  %89 = getelementptr inbounds nuw i32, ptr %78, i64 %88
  %90 = getelementptr inbounds nuw i8, ptr %89, i64 16
  %91 = load <4 x i32>, ptr %89, align 16, !tbaa !5
  %92 = load <4 x i32>, ptr %90, align 16, !tbaa !5
  %93 = getelementptr inbounds nuw i32, ptr %79, i64 %88
  %94 = getelementptr inbounds nuw i8, ptr %93, i64 16
  store <4 x i32> %91, ptr %93, align 16, !tbaa !5
  store <4 x i32> %92, ptr %94, align 16, !tbaa !5
  store <4 x i32> zeroinitializer, ptr %89, align 16, !tbaa !5
  store <4 x i32> zeroinitializer, ptr %90, align 16, !tbaa !5
  %95 = add nuw nsw i64 %81, 16
  %96 = icmp eq i64 %95, 192
  br i1 %96, label %98, label %80, !llvm.loop !13

97:                                               ; preds = %98
  ret void

98:                                               ; preds = %80
  %99 = add nuw nsw i64 %77, 1
  %100 = icmp eq i64 %99, 384
  br i1 %100, label %97, label %76, !llvm.loop !16
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(readwrite, argmem: none, inaccessiblemem: none, target_mem0: none, target_mem1: none) uwtable
define dso_local void @addSand(i32 noundef %0) local_unnamed_addr #2 {
  %2 = lshr i32 %0, 16
  %3 = trunc nuw i32 %2 to i16
  %4 = sdiv i16 %3, 4
  %5 = lshr i32 %0, 2
  %6 = and i32 %5, 16383
  %7 = sext i16 %4 to i64
  %8 = getelementptr inbounds [192 x i32], ptr @field, i64 %7
  %9 = zext nneg i32 %6 to i64
  %10 = getelementptr inbounds nuw i32, ptr %8, i64 %9
  %11 = load i32, ptr %10, align 4, !tbaa !5
  %12 = add nsw i32 %11, 64
  store i32 %12, ptr %10, align 4, !tbaa !5
  ret void
}

; Function Attrs: noreturn nounwind sspstrong uwtable
define dso_local void @app() local_unnamed_addr #3 {
  br label %1

1:                                                ; preds = %0, %25
  %2 = tail call i32 (...) @simHasClick() #6
  %3 = icmp eq i32 %2, 0
  br i1 %3, label %19, label %4

4:                                                ; preds = %1, %4
  %5 = tail call i32 (...) @simGetClick() #6
  %6 = lshr i32 %5, 16
  %7 = trunc nuw i32 %6 to i16
  %8 = sdiv i16 %7, 4
  %9 = lshr i32 %5, 2
  %10 = and i32 %9, 16383
  %11 = sext i16 %8 to i64
  %12 = getelementptr inbounds [192 x i32], ptr @field, i64 %11
  %13 = zext nneg i32 %10 to i64
  %14 = getelementptr inbounds nuw i32, ptr %12, i64 %13
  %15 = load i32, ptr %14, align 4, !tbaa !5
  %16 = add nsw i32 %15, 64
  store i32 %16, ptr %14, align 4, !tbaa !5
  %17 = tail call i32 (...) @simHasClick() #6
  %18 = icmp eq i32 %17, 0
  br i1 %18, label %19, label %4, !llvm.loop !17

19:                                               ; preds = %4, %1
  tail call void @simulate()
  br label %20

20:                                               ; preds = %19, %26
  %21 = phi i32 [ 0, %19 ], [ %27, %26 ]
  %22 = lshr i32 %21, 2
  %23 = zext nneg i32 %22 to i64
  %24 = getelementptr inbounds nuw [192 x i32], ptr @field, i64 %23
  br label %29

25:                                               ; preds = %26
  tail call void (...) @simFlush() #6
  br label %1

26:                                               ; preds = %47
  %27 = add nuw nsw i32 %21, 1
  %28 = icmp eq i32 %27, 1536
  br i1 %28, label %25, label %20, !llvm.loop !18

29:                                               ; preds = %20, %47
  %30 = phi i32 [ 0, %20 ], [ %49, %47 ]
  %31 = lshr i32 %30, 2
  %32 = zext nneg i32 %31 to i64
  %33 = getelementptr inbounds nuw i32, ptr %24, i64 %32
  %34 = load i32, ptr %33, align 4, !tbaa !5
  %35 = icmp ult i32 %34, 4
  br i1 %35, label %43, label %36

36:                                               ; preds = %29
  %37 = tail call i32 @llvm.smin.i32(i32 %34, i32 512)
  %38 = mul nsw i32 %37, 191
  %39 = sdiv i32 %38, 512
  %40 = shl i32 %39, 16
  %41 = add i32 %40, 4194304
  %42 = or i32 %41, -16777216
  br label %47

43:                                               ; preds = %29
  %44 = zext nneg i32 %34 to i64
  %45 = getelementptr inbounds nuw i32, ptr @switch.table.app, i64 %44
  %46 = load i32, ptr %45, align 4
  br label %47

47:                                               ; preds = %43, %36
  %48 = phi i32 [ %42, %36 ], [ %46, %43 ]
  tail call void @simPutPixel(i32 noundef %21, i32 noundef %30, i32 noundef %48) #6
  %49 = add nuw nsw i32 %30, 1
  %50 = icmp eq i32 %49, 768
  br i1 %50, label %26, label %29, !llvm.loop !19
}

declare i32 @simHasClick(...) local_unnamed_addr #4

declare i32 @simGetClick(...) local_unnamed_addr #4

declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #4

declare void @simFlush(...) local_unnamed_addr #4

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #5

attributes #0 = { mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree norecurse nosync nounwind sspstrong memory(readwrite, argmem: none, inaccessiblemem: none, target_mem0: none, target_mem1: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(readwrite, argmem: none, inaccessiblemem: none, target_mem0: none, target_mem1: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { noreturn nounwind sspstrong uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #6 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}
!llvm.errno.tbaa = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 22.1.6"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = distinct !{!9, !10}
!10 = !{!"llvm.loop.mustprogress"}
!11 = distinct !{!11, !10, !12}
!12 = !{!"llvm.loop.peeled.count", i32 1}
!13 = distinct !{!13, !10, !14, !15}
!14 = !{!"llvm.loop.isvectorized", i32 1}
!15 = !{!"llvm.loop.unroll.runtime.disable"}
!16 = distinct !{!16, !10}
!17 = distinct !{!17, !10}
!18 = distinct !{!18, !10}
!19 = distinct !{!19, !10}
