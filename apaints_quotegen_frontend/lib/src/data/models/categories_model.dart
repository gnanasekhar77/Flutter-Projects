class GetCategoriesModel {
  List<CategoryData>? data;
  String? statusMessage;
  String? status;

  GetCategoriesModel({this.data, this.statusMessage, this.status});

  GetCategoriesModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CategoryData>[];
      json['data'].forEach((v) {
        data!.add(CategoryData.fromJson(v));
      });
    }
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class CategoryData {
  String? category;
  String? categoryImage;
  List<LIST>? list;

  CategoryData({this.category, this.categoryImage, this.list});

  CategoryData.fromJson(Map<String, dynamic> json) {
    category = json['CATEGORY'];
    categoryImage = json['CATEGORYIMAGE'];

    if (json['LIST'] != null) {
      list = <LIST>[];
      json['LIST'].forEach((v) {
        list!.add(LIST.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CATEGORY'] = category;
    data['CATEGORYIMAGE'] = categoryImage;

    if (list != null) {
      data['LIST'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LIST {
  String? brandImage;
  String? brand;
  List<RANGE>? range;

  LIST({this.brandImage, this.brand, this.range});

  LIST.fromJson(Map<String, dynamic> json) {
    brandImage = json['BRANDIMAGE'];
    brand = json['BRAND'];
    if (json['RANGE'] != null) {
      range = <RANGE>[];
      json['RANGE'].forEach((v) {
        range!.add(RANGE.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BRANDIMAGE'] = brandImage;

    data['BRAND'] = brand;
    if (range != null) {
      data['RANGE'] = range!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RANGE {
  String? skuRange;
  String? rangeImage;

  RANGE({this.skuRange, this.rangeImage});

  RANGE.fromJson(Map<String, dynamic> json) {
    skuRange = json['SKU_RANGE'];
    rangeImage = json['RANGEIMAGE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SKU_RANGE'] = skuRange;
    data['RANGEIMAGE'] = rangeImage;

    return data;
  }
}
