import '../flyer.dart';

class TemplateData {
  String? posterType;
  List<TemplatePage>? pages;

  TemplateData({this.posterType, this.pages});

  factory TemplateData.fromJson(
      Map<String, dynamic> json,
      double newPosterWidth,
      double newPosterHeight,
      ) {
    return TemplateData(
      posterType: json['posterType'],
      pages: (json['pages'] as List<dynamic>?)
          ?.map((e) => TemplatePage.fromJson(e, newPosterWidth, newPosterHeight))
          .toList(),
    );
  }

}
