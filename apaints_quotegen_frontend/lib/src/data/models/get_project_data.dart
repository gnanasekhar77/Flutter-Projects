class ProjectDataModel {
  int? totalBeforeGST;
  int? totalAfterGST;
  int? totalDiscountAmount;

  int get getTotalBeforeGST => totalBeforeGST??0;

  set setTotalBeforeGST(int value) => totalBeforeGST = value;

  int get getTotalAfterGST => totalAfterGST??0;

  set setTotalAfterGST(int value) => totalAfterGST = value;

  int get getTotalDiscountAmount => totalDiscountAmount??0;

  set setTotalDiscountAmount(int value) => totalDiscountAmount = value;
}
