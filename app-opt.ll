; ModuleID = 'app.c'
source_filename = "app.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@switch.table.app = private unnamed_addr constant [4 x i32] [i32 -16777216, i32 -16736256, i32 -8388480, i32 -10496], align 4

; Function Attrs: mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(none) uwtable
define dso_local range(i32 -4096, 4096) i32 @getX(i32 noundef %0) local_unnamed_addr #0 {
  %2 = lshr i32 %0, 16
  %3 = trunc nuw i32 %2 to i16
  %4 = sdiv i16 %3, 8
  %5 = sext i16 %4 to i32
  ret i32 %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(none) uwtable
define dso_local noundef range(i32 0, 8192) i32 @getY(i32 noundef %0) local_unnamed_addr #0 {
  %2 = lshr i32 %0, 3
  %3 = and i32 %2, 8191
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

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: nofree norecurse nosync nounwind sspstrong memory(argmem: readwrite) uwtable
define dso_local void @simulate(ptr noundef captures(none) %0) local_unnamed_addr #2 {
  %2 = alloca [192 x [96 x i32]], align 16
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #9
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(73728) %2, i8 0, i64 73728, i1 false)
  br label %3

3:                                                ; preds = %1, %36
  %4 = phi i64 [ 0, %1 ], [ %37, %36 ]
  %5 = getelementptr inbounds nuw [96 x i32], ptr %0, i64 %4
  %6 = getelementptr inbounds nuw [96 x i32], ptr %2, i64 %4
  %7 = add nsw i64 %4, -1
  %8 = icmp ult i64 %7, 192
  %9 = getelementptr inbounds nuw [96 x i32], ptr %2, i64 %7
  %10 = icmp samesign ult i64 %4, 191
  %11 = getelementptr inbounds nuw [96 x i32], ptr %2, i64 %4
  %12 = getelementptr inbounds nuw i8, ptr %11, i64 384
  br label %40

13:                                               ; preds = %76
  %14 = getelementptr inbounds nuw i32, ptr %5, i64 %77
  %15 = load i32, ptr %14, align 4, !tbaa !5
  %16 = getelementptr inbounds nuw i32, ptr %6, i64 %77
  %17 = load i32, ptr %16, align 4, !tbaa !5
  %18 = add nsw i32 %17, %15
  store i32 %18, ptr %16, align 4, !tbaa !5
  %19 = icmp sgt i32 %15, 3
  br i1 %19, label %20, label %36

20:                                               ; preds = %13
  br i1 %8, label %21, label %25

21:                                               ; preds = %20
  %22 = getelementptr inbounds nuw i32, ptr %9, i64 %77
  %23 = load i32, ptr %22, align 4, !tbaa !5
  %24 = add nsw i32 %23, 1
  store i32 %24, ptr %22, align 4, !tbaa !5
  br label %25

25:                                               ; preds = %20, %21
  %26 = getelementptr i32, ptr %6, i64 %77
  %27 = getelementptr i8, ptr %26, i64 -4
  %28 = load i32, ptr %27, align 8, !tbaa !5
  %29 = add nsw i32 %28, 1
  store i32 %29, ptr %27, align 8, !tbaa !5
  br i1 %10, label %30, label %34

30:                                               ; preds = %25
  %31 = getelementptr inbounds nuw i32, ptr %12, i64 %77
  %32 = load i32, ptr %31, align 4, !tbaa !5
  %33 = add nsw i32 %32, 1
  store i32 %33, ptr %31, align 4, !tbaa !5
  br label %34

34:                                               ; preds = %25, %30
  %35 = add nsw i32 %18, -4
  store i32 %35, ptr %16, align 4, !tbaa !5
  br label %36

36:                                               ; preds = %34, %13
  %37 = add nuw nsw i64 %4, 1
  %38 = icmp eq i64 %37, 192
  br i1 %38, label %39, label %3, !llvm.loop !9

39:                                               ; preds = %36
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(73728) %0, ptr noundef nonnull align 16 dereferenceable(73728) %2, i64 73728, i1 false), !tbaa !5
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #9
  ret void

40:                                               ; preds = %3, %76
  %41 = phi i64 [ 0, %3 ], [ %77, %76 ]
  %42 = getelementptr inbounds nuw i32, ptr %5, i64 %41
  %43 = load i32, ptr %42, align 4, !tbaa !5
  %44 = getelementptr inbounds nuw i32, ptr %6, i64 %41
  %45 = load i32, ptr %44, align 4, !tbaa !5
  %46 = add nsw i32 %45, %43
  store i32 %46, ptr %44, align 4, !tbaa !5
  %47 = icmp sgt i32 %43, 3
  br i1 %47, label %50, label %48

48:                                               ; preds = %40
  %49 = add nuw nsw i64 %41, 1
  br label %76

50:                                               ; preds = %40
  br i1 %8, label %51, label %55

51:                                               ; preds = %50
  %52 = getelementptr inbounds nuw i32, ptr %9, i64 %41
  %53 = load i32, ptr %52, align 4, !tbaa !5
  %54 = add nsw i32 %53, 1
  store i32 %54, ptr %52, align 4, !tbaa !5
  br label %55

55:                                               ; preds = %51, %50
  %56 = add nsw i64 %41, -1
  %57 = icmp ult i64 %56, 96
  br i1 %57, label %58, label %62

58:                                               ; preds = %55
  %59 = getelementptr inbounds nuw i32, ptr %6, i64 %56
  %60 = load i32, ptr %59, align 4, !tbaa !5
  %61 = add nsw i32 %60, 1
  store i32 %61, ptr %59, align 4, !tbaa !5
  br label %62

62:                                               ; preds = %58, %55
  br i1 %10, label %63, label %67

63:                                               ; preds = %62
  %64 = getelementptr inbounds nuw i32, ptr %12, i64 %41
  %65 = load i32, ptr %64, align 4, !tbaa !5
  %66 = add nsw i32 %65, 1
  store i32 %66, ptr %64, align 4, !tbaa !5
  br label %67

67:                                               ; preds = %63, %62
  %68 = add nuw nsw i64 %41, 1
  %69 = icmp ult i64 %41, 95
  br i1 %69, label %70, label %74

70:                                               ; preds = %67
  %71 = getelementptr inbounds nuw i32, ptr %6, i64 %68
  %72 = load i32, ptr %71, align 4, !tbaa !5
  %73 = add nsw i32 %72, 1
  store i32 %73, ptr %71, align 4, !tbaa !5
  br label %74

74:                                               ; preds = %70, %67
  %75 = add nsw i32 %46, -4
  store i32 %75, ptr %44, align 4, !tbaa !5
  br label %76

76:                                               ; preds = %48, %74
  %77 = phi i64 [ %49, %48 ], [ %68, %74 ]
  %78 = icmp eq i64 %77, 95
  br i1 %78, label %13, label %40, !llvm.loop !11
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #3

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(argmem: readwrite) uwtable
define dso_local void @addSand(ptr noundef captures(none) %0, i32 noundef %1) local_unnamed_addr #5 {
  %3 = lshr i32 %1, 16
  %4 = trunc nuw i32 %3 to i16
  %5 = sdiv i16 %4, 8
  %6 = lshr i32 %1, 3
  %7 = and i32 %6, 8191
  %8 = sext i16 %5 to i64
  %9 = getelementptr inbounds [96 x i32], ptr %0, i64 %8
  %10 = zext nneg i32 %7 to i64
  %11 = getelementptr inbounds nuw i32, ptr %9, i64 %10
  %12 = load i32, ptr %11, align 4, !tbaa !5
  %13 = add nsw i32 %12, 64
  store i32 %13, ptr %11, align 4, !tbaa !5
  ret void
}

; Function Attrs: noreturn nounwind sspstrong uwtable
define dso_local void @app() local_unnamed_addr #6 {
  %1 = alloca [192 x [96 x i32]], align 16
  %2 = alloca [192 x [96 x i32]], align 16
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #9
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(73728) %2, i8 0, i64 73728, i1 false)
  br label %3

3:                                                ; preds = %101, %0
  %4 = tail call i32 (...) @simHasClick() #9
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %21, label %6

6:                                                ; preds = %3, %6
  %7 = tail call i32 (...) @simGetClick() #9
  %8 = lshr i32 %7, 16
  %9 = trunc nuw i32 %8 to i16
  %10 = sdiv i16 %9, 8
  %11 = lshr i32 %7, 3
  %12 = and i32 %11, 8191
  %13 = sext i16 %10 to i64
  %14 = getelementptr inbounds [96 x i32], ptr %2, i64 %13
  %15 = zext nneg i32 %12 to i64
  %16 = getelementptr inbounds nuw i32, ptr %14, i64 %15
  %17 = load i32, ptr %16, align 4, !tbaa !5
  %18 = add nsw i32 %17, 64
  store i32 %18, ptr %16, align 4, !tbaa !5
  %19 = tail call i32 (...) @simHasClick() #9
  %20 = icmp eq i32 %19, 0
  br i1 %20, label %21, label %6, !llvm.loop !13

21:                                               ; preds = %6, %3
  call void @llvm.lifetime.start.p0(ptr nonnull %1) #9
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(73728) %1, i8 0, i64 73728, i1 false)
  br label %22

22:                                               ; preds = %53, %21
  %23 = phi i64 [ 0, %21 ], [ %54, %53 ]
  %24 = getelementptr inbounds nuw [96 x i32], ptr %2, i64 %23
  %25 = getelementptr inbounds nuw [96 x i32], ptr %1, i64 %23
  %26 = add nsw i64 %23, -1
  %27 = icmp ult i64 %26, 192
  %28 = getelementptr inbounds nuw [96 x i32], ptr %1, i64 %26
  %29 = icmp samesign ult i64 %23, 191
  %30 = getelementptr inbounds nuw i8, ptr %25, i64 384
  br label %56

31:                                               ; preds = %92
  %32 = getelementptr inbounds nuw i8, ptr %24, i64 380
  %33 = load i32, ptr %32, align 4, !tbaa !5
  %34 = getelementptr inbounds nuw i8, ptr %25, i64 380
  %35 = load i32, ptr %34, align 4, !tbaa !5
  %36 = add nsw i32 %35, %33
  store i32 %36, ptr %34, align 4, !tbaa !5
  %37 = icmp sgt i32 %33, 3
  br i1 %37, label %38, label %53

38:                                               ; preds = %31
  br i1 %27, label %39, label %43

39:                                               ; preds = %38
  %40 = getelementptr inbounds nuw i8, ptr %28, i64 380
  %41 = load i32, ptr %40, align 4, !tbaa !5
  %42 = add nsw i32 %41, 1
  store i32 %42, ptr %40, align 4, !tbaa !5
  br label %43

43:                                               ; preds = %39, %38
  %44 = getelementptr inbounds nuw i8, ptr %25, i64 376
  %45 = load i32, ptr %44, align 8, !tbaa !5
  %46 = add nsw i32 %45, 1
  store i32 %46, ptr %44, align 8, !tbaa !5
  br i1 %29, label %47, label %51

47:                                               ; preds = %43
  %48 = getelementptr inbounds nuw i8, ptr %25, i64 764
  %49 = load i32, ptr %48, align 4, !tbaa !5
  %50 = add nsw i32 %49, 1
  store i32 %50, ptr %48, align 4, !tbaa !5
  br label %51

51:                                               ; preds = %43, %47
  %52 = add nsw i32 %36, -4
  store i32 %52, ptr %34, align 4, !tbaa !5
  br label %53

53:                                               ; preds = %31, %51
  %54 = add nuw nsw i64 %23, 1
  %55 = icmp eq i64 %54, 192
  br i1 %55, label %95, label %22, !llvm.loop !9

56:                                               ; preds = %92, %22
  %57 = phi i64 [ 0, %22 ], [ %93, %92 ]
  %58 = getelementptr inbounds nuw i32, ptr %24, i64 %57
  %59 = load i32, ptr %58, align 4, !tbaa !5
  %60 = getelementptr inbounds nuw i32, ptr %25, i64 %57
  %61 = load i32, ptr %60, align 4, !tbaa !5
  %62 = add nsw i32 %61, %59
  store i32 %62, ptr %60, align 4, !tbaa !5
  %63 = icmp sgt i32 %59, 3
  br i1 %63, label %66, label %64

64:                                               ; preds = %56
  %65 = add nuw nsw i64 %57, 1
  br label %92

66:                                               ; preds = %56
  br i1 %27, label %67, label %71

67:                                               ; preds = %66
  %68 = getelementptr inbounds nuw i32, ptr %28, i64 %57
  %69 = load i32, ptr %68, align 4, !tbaa !5
  %70 = add nsw i32 %69, 1
  store i32 %70, ptr %68, align 4, !tbaa !5
  br label %71

71:                                               ; preds = %67, %66
  %72 = add nsw i64 %57, -1
  %73 = icmp ult i64 %72, 96
  br i1 %73, label %74, label %78

74:                                               ; preds = %71
  %75 = getelementptr inbounds nuw i32, ptr %25, i64 %72
  %76 = load i32, ptr %75, align 4, !tbaa !5
  %77 = add nsw i32 %76, 1
  store i32 %77, ptr %75, align 4, !tbaa !5
  br label %78

78:                                               ; preds = %74, %71
  br i1 %29, label %79, label %83

79:                                               ; preds = %78
  %80 = getelementptr inbounds nuw i32, ptr %30, i64 %57
  %81 = load i32, ptr %80, align 4, !tbaa !5
  %82 = add nsw i32 %81, 1
  store i32 %82, ptr %80, align 4, !tbaa !5
  br label %83

83:                                               ; preds = %79, %78
  %84 = add nuw nsw i64 %57, 1
  %85 = icmp samesign ult i64 %57, 95
  br i1 %85, label %86, label %90

86:                                               ; preds = %83
  %87 = getelementptr inbounds nuw i32, ptr %25, i64 %84
  %88 = load i32, ptr %87, align 4, !tbaa !5
  %89 = add nsw i32 %88, 1
  store i32 %89, ptr %87, align 4, !tbaa !5
  br label %90

90:                                               ; preds = %86, %83
  %91 = add nsw i32 %62, -4
  store i32 %91, ptr %60, align 4, !tbaa !5
  br label %92

92:                                               ; preds = %90, %64
  %93 = phi i64 [ %65, %64 ], [ %84, %90 ]
  %94 = icmp eq i64 %93, 95
  br i1 %94, label %31, label %56, !llvm.loop !14

95:                                               ; preds = %53
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 16 dereferenceable(73728) %2, ptr noundef nonnull align 16 dereferenceable(73728) %1, i64 73728, i1 false), !tbaa !5
  call void @llvm.lifetime.end.p0(ptr nonnull %1) #9
  br label %96

96:                                               ; preds = %95, %102
  %97 = phi i32 [ 0, %95 ], [ %103, %102 ]
  %98 = lshr i32 %97, 3
  %99 = zext nneg i32 %98 to i64
  %100 = getelementptr inbounds nuw [96 x i32], ptr %2, i64 %99
  br label %105

101:                                              ; preds = %102
  tail call void (...) @simFlush() #9
  br label %3

102:                                              ; preds = %123
  %103 = add nuw nsw i32 %97, 1
  %104 = icmp eq i32 %103, 1536
  br i1 %104, label %101, label %96, !llvm.loop !15

105:                                              ; preds = %96, %123
  %106 = phi i32 [ 0, %96 ], [ %125, %123 ]
  %107 = lshr i32 %106, 3
  %108 = zext nneg i32 %107 to i64
  %109 = getelementptr inbounds nuw i32, ptr %100, i64 %108
  %110 = load i32, ptr %109, align 4, !tbaa !5
  %111 = icmp ult i32 %110, 4
  br i1 %111, label %119, label %112

112:                                              ; preds = %105
  %113 = tail call i32 @llvm.smin.i32(i32 %110, i32 512)
  %114 = mul nsw i32 %113, 191
  %115 = sdiv i32 %114, 512
  %116 = shl i32 %115, 16
  %117 = add i32 %116, 4194304
  %118 = or i32 %117, -16777216
  br label %123

119:                                              ; preds = %105
  %120 = zext nneg i32 %110 to i64
  %121 = getelementptr inbounds nuw i32, ptr @switch.table.app, i64 %120
  %122 = load i32, ptr %121, align 4
  br label %123

123:                                              ; preds = %119, %112
  %124 = phi i32 [ %118, %112 ], [ %122, %119 ]
  tail call void @simPutPixel(i32 noundef %97, i32 noundef %106, i32 noundef %124) #9
  %125 = add nuw nsw i32 %106, 1
  %126 = icmp eq i32 %125, 768
  br i1 %126, label %102, label %105, !llvm.loop !16
}

declare i32 @simHasClick(...) local_unnamed_addr #7

declare i32 @simGetClick(...) local_unnamed_addr #7

declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #7

declare void @simFlush(...) local_unnamed_addr #7

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #8

attributes #0 = { mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nofree norecurse nosync nounwind sspstrong memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #5 = { mustprogress nofree norecurse nosync nounwind sspstrong willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { noreturn nounwind sspstrong uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #9 = { nounwind }

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
!13 = distinct !{!13, !10}
!14 = distinct !{!14, !10, !12}
!15 = distinct !{!15, !10}
!16 = distinct !{!16, !10}
