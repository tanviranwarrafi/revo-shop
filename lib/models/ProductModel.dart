import 'package:nyoba/services/Session.dart';

class ProductModel {
  int id, productStock, ratingCount, cartQuantity, variantId;
  double discProduct, priceTotal;
  String productName,
      productSlug,
      productDescription,
      productShortDesc,
      productSku,
      formattedPrice,
      formattedSalesPrice,
      avgRating,
      link,
      stockStatus,
      type;
  var productPrice, productRegPrice, productSalePrice, totalSales;
  bool isSelected = false;
  bool isProductWholeSale = false;
  bool manageStock = false;
  List<ProductImageModel> images;
  List<ProductCategoryModel> categories;
  List<ProductAttributeModel> attributes;
  List<ProductMetaData> metaData;
  List<ProductVideo> videos;
  List<ProductVariation> selectedVariation = [];
  String variationName;
  List<double> variationPrices = [];

  ProductModel(
      {this.id,
      this.totalSales,
      this.productStock,
      this.productName,
      this.productSlug,
      this.productDescription,
      this.productShortDesc,
      this.productSku,
      this.productPrice,
      this.productRegPrice,
      this.productSalePrice,
      this.images,
      this.categories,
      this.ratingCount,
      this.avgRating,
      this.discProduct,
      this.attributes,
      this.cartQuantity,
      this.isSelected,
      this.priceTotal,
      this.variantId,
      this.link,
      this.metaData,
      this.videos,
      this.stockStatus,
      this.type,
      this.selectedVariation,
      this.variationName,
      this.variationPrices});

  Map toJson() => {
        'id': id,
        'total_sales': totalSales,
        'stock_quantity': productStock,
        'name': productName,
        'slug': productSlug,
        'description': productDescription,
        'short_description': productShortDesc,
        'formated_price': formattedPrice,
        'formated_sales_price': formattedSalesPrice,
        'sku': productSku,
        'price': productPrice,
        'regular_price': productRegPrice,
        'sale_price': productSalePrice,
        'images': images,
        'categories': categories,
        'average_rating': avgRating,
        'rating_count': ratingCount,
        'attributes': attributes,
        'disc': discProduct,
        'cart_quantity': cartQuantity,
        'is_selected': isSelected,
        'price_total': priceTotal,
        'variant_id': variantId,
        'permalink': link,
        'meta_data': metaData,
        'videos': videos,
        'manage_stock': manageStock,
        'stock_status': stockStatus,
        'type': type,
        'selected_variation': selectedVariation,
        'variation_name': variationName,
        'variation_prices': variationPrices
      };

  ProductModel.fromJson(Map json) {
    id = json['id'];
    totalSales = json['total_sales'];
    productStock =
        json['manage_stock'] == false ? 999 : json['stock_quantity'] ?? 0;
    stockStatus = json['stock_status'];
    productName = json['name'];
    productSlug = json['slug'];
    productDescription = json['description'];
    productShortDesc = json['short_description'];
    productSku = json['sku'];
    link = json['permalink'];
    manageStock = json['manage_stock'];
    type = json['type'];
    productPrice = json['price'] != null && json['price'] != ''
        ? json['price'].toString()
        : '0';
    productRegPrice =
        json['regular_price'] != null && json['regular_price'] != ''
            ? json['regular_price'].toString()
            : '0';
    productSalePrice = json['sale_price'] != null && json['sale_price'] != ''
        ? json['sale_price'].toString()
        : '';
    avgRating = json['average_rating'];
    ratingCount = json['rating_count'];
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images.add(new ProductImageModel.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories.add(new ProductCategoryModel.fromJson(v));
      });
    }
    if (json['attributes'] != null) {
      attributes = [];
      json['attributes'].forEach((v) {
        attributes.add(new ProductAttributeModel.fromJson(v));
      });
    }
    cartQuantity = json['cart_quantity'];
    discProduct = productSalePrice.isNotEmpty && productSalePrice != "0"
        ? discProduct =
            ((double.parse(productRegPrice) - double.parse(productSalePrice)) /
                    double.parse(productRegPrice)) *
                100
        : discProduct = 0;
    isSelected = json['is_selected'];
    priceTotal = json['price_total'];
    variantId = json['variant_id'];
    if (json['meta_data'] != null) {
      metaData = [];
      videos = [];
      json['meta_data'].forEach((v) {
        metaData.add(new ProductMetaData.fromJson(v));
        if (v['key'] == 'wholesale_customer_have_wholesale_price' &&
            v['value'] == 'yes') {
          isProductWholeSale = true;
        }
        if (v['key'] == '_ywcfav_video') {
          v['value'].forEach((valVideo) {
            videos.add(new ProductVideo.fromJson(valVideo));
          });
        }
      });
    }
    if (isProductWholeSale &&
        Session.data.getString('role') == 'wholesale_customer') {
      metaData.forEach((element) {
        if (element.key == 'wholesale_customer_wholesale_price' &&
            element.value.toString().isNotEmpty) {
          discProduct = 0;
          productSalePrice = "0";
          productRegPrice = "0";
          productPrice = element.value;
        }
      });
    }
    if (json['selected_variation'] != null) {
      selectedVariation = [];
      json['selected_variation'].forEach((v) {
        selectedVariation.add(new ProductVariation.fromJson(v));
      });
    }
    if (json['variation_name'] != null) {
      variationName = json['variation_name'];
    }
    if (json['availableVariations'] != null) {
      json['availableVariations'].forEach((v) {
        variationPrices.add(v['display_price'].toDouble());
      });
      variationPrices.sort((a, b) => a.compareTo(b));
    }
    if (isProductWholeSale &&
        Session.data.getString('role') == 'wholesale_customer') {
      if (json['wholesales'] != null) {
        variationPrices.clear();
        json['wholesales'].forEach((v) {
          variationPrices.add(double.parse(v['price']));
        });
        variationPrices.sort((a, b) => a.compareTo(b));
      }
    }
  }

  @override
  String toString() {
    return 'ProductModel{id: $id, totalSales: $totalSales, productStock: $productStock, ratingCount: $ratingCount, cartQuantity: $cartQuantity, priceTotal: $priceTotal, variantId: $variantId, discProduct: $discProduct, productName: $productName, productSlug: $productSlug, productDescription: $productDescription, productShortDesc: $productShortDesc, productSku: $productSku, productPrice: $productPrice, productRegPrice: $productRegPrice, productSalePrice: $productSalePrice, avgRating: $avgRating, link: $link, isSelected: $isSelected, images: $images, categories: $categories, attributes: $attributes}';
  }
}

class ProductImageModel {
  int id;
  String dateCreated, dateModified, src, name, alt;

  ProductImageModel(
      {this.dateCreated,
      this.dateModified,
      this.src,
      this.name,
      this.alt,
      this.id});

  Map toJson() => {
        'id': id,
        'date_created': dateCreated,
        'date_modified': dateModified,
        'src': src,
        'name': name,
        'alt': alt,
      };

  ProductImageModel.fromJson(Map json)
      : id = json['id'],
        dateCreated = json['date_created'],
        dateModified = json['date_modified'],
        src = json['src'],
        name = json['name'],
        alt = json['alt'];
}

class ProductCategoryModel {
  int id;
  String name, slug;
  var image;

  ProductCategoryModel({this.slug, this.name, this.id, this.image});

  Map toJson() => {'id': id, 'name': name, 'slug': slug, 'image': image};

  ProductCategoryModel.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    if (json['image'] != null && json['image'] != '') {
      if (json['image'] != false && json['image']['src'] != false) {
        image = json['image']['src'];
      }
    }
  }
}

class ProductAttributeModel {
  int id, position;
  String name, selectedVariant;
  bool visible, variation;
  List<dynamic> options;

  ProductAttributeModel(
      {this.id,
      this.position,
      this.name,
      this.visible,
      this.variation,
      this.options,
      this.selectedVariant});

  Map toJson() => {
        'id': id,
        'position': position,
        'name': name,
        'visible': visible,
        'variation': variation,
        'options': options,
        'selected_variant': selectedVariant
      };

  ProductAttributeModel.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        position = json['position'],
        visible = json['visible'],
        variation = json['variation'],
        options = json['options'],
        selectedVariant = json['selected_variant'];
}

class ProductVariation {
  int id;
  String columnName;
  String value;

  ProductVariation({this.id, this.value, this.columnName});

  Map toJson() => {
        'id': id,
        'column_name': columnName,
        'value': value,
      };

  ProductVariation.fromJson(Map json)
      : id = json['id'],
        columnName = json['column_name'],
        value = json['value'];

  @override
  String toString() {
    return 'ProductVariation{columnName: $columnName, value: $value}';
  }
}

class ProductMetaData {
  int id;
  String key;
  var value;

  ProductMetaData({this.id, this.key, this.value});

  Map toJson() => {
        'id': id,
        'key': key,
        'value': value,
      };

  ProductMetaData.fromJson(Map json)
      : id = json['id'],
        key = json['key'],
        value = json['value'];
}

class ProductVideo {
  String thumbnail, id, type, featured, name, host, content;

  ProductVideo(
      {this.thumbnail,
      this.id,
      this.type,
      this.featured,
      this.name,
      this.host,
      this.content});

  Map toJson() => {
        'thumbnail': thumbnail,
        'id': id,
        'type': type,
        'featured': featured,
        'name': name,
        'host': host,
        'content': content,
      };

  ProductVideo.fromJson(Map json)
      : thumbnail = json['thumbn'],
        id = json['id'],
        type = json['type'],
        featured = json['featured'],
        name = json['name'],
        host = json['host'],
        content = json['content'];
}
