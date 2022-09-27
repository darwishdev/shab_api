package model

type Article struct {
	Id           uint
	UserId       uint
	CatId        uint
	ViewsCounter uint
	CategoryName string
	UserImg      string
	UserName     string
	Title        string
	Img          string
	Status       string
	Content      string
	Created_at   string
	Published_at string
	Views        int
}

type ArticlesListReq struct {
	Category int    `query:"CatId"`
	UserName string `query:"UserName"`
	DateFrom string `query:"DateFrom"`
	DateTo   string `query:"DateTo"`
	Search   string `query:"Name"`
}
type ArticleList struct {
	Id           uint
	CategoryName string
	ViewsCounter int
	UserName     string
	UserImg      string
	Title        string
	Img          string
	Views        int
	Published_at string
}

type ArticleCreateReq struct {
	UserId       uint
	CatId        uint64
	ViewsCounter int
	Img          string
	Content      string
	Title        string
	Status       string
}
