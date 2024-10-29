
class PaginationDTO {
  int? totalItems;
  int? totalItemsPerPage;
  int? currentPage;
  int? totalPages;

  PaginationDTO(
      {this.totalItems,
        this.totalItemsPerPage,
        this.currentPage,
        this.totalPages});

  PaginationDTO.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    totalItemsPerPage = json['totalItemsPerPage'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalItems'] = totalItems;
    data['totalItemsPerPage'] = totalItemsPerPage;
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
    return data;
  }
}