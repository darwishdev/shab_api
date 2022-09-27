package model

type Consultunt struct {
	Id      int
	NameAr  string
	Title   string
	Skills  string
	Skills1 string
	Skills2 string
	Skills3 string
	IsTeam  bool
	Image   string
	Breif   string
}
type ConsultuntListReq struct {
	Name   string `query:"Name"`
	Title  string `query:"Title"`
	Skills string `query:"Skills"`
	IsTeam bool   `query:"IsTeam"`
}
type ConsultuntCreateReq struct {
	Name    string
	Title   string
	Skills  string
	Skills1 string
	Skills2 string
	Skills3 string
	Img     string `json:"Image"`
	IsTeam  bool
	Breif   string
}
