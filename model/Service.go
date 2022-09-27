package model

type Service struct {
	// Key   string
	Id   int
	Name string
	Icon string
}
type ServiceReq struct {
	Id        int
	Name      string
	Email     string
	Phone     string
	Breif     string
	CreatedAt string
}
