package model

type Event struct {
	Id         uint
	Title      string
	Img        string
	Breif      string
	Day        string
	Month      string
	Year       string
	Date       string
	Price      float64
	Featured   bool
	Created_at string
	CatName    string
	CatId      uint
	Video      string
}

type EventListReq struct {
	Featured  *bool   `query:"Featured"`
	Title     string  `query:"Title"`
	Status    string  `query:"Status"`
	Category  int     `query:"CatId"`
	PriceFrom float64 `query:"PriceFrom"`
	PriceTo   float64 `query:"PriceTo"`
	DateFrom  string  `query:"DateFrom"`
	DateTo    string  `query:"DateTo"`
}
type EventRequest struct {
	Title    string
	Img      string `json:"Image"`
	Breif    string
	Date     string
	Price    float64
	Featured bool
	CatId    uint
	Video    string
}
