package model

type Role struct {
	Id     uint
	Name   string
	Img    string
	Breif  string
	Price  float64
	Color  string
	Active bool
}

type Feature struct {
	Id    int
	Name  string
	Breif string
	Level int
}
