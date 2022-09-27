package model

type Video struct {
	Id           uint64
	Name         string
	Url          string
	Image        string
	Breif        string
	CatId        uint
	CategoryName string
}

type VideoCreateReq struct {
	Name  string
	Url   string
	Image string
	Breif string
	CatId uint
}
