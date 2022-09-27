package model

type UserPending struct {
	Id        int
	NameAr    string
	Email     string
	Type      string
	RoleName  string
	Phone     string
	Status    string
	CreatedAt string
}

type ProjectsPendingListReq struct {
	Status   string `query:"Status"`
	Name     string `query:"Name"`
	Title    string `query:"Title"`
	Phone    string `query:"Phone"`
	Email    string `query:"Email"`
	DateFrom string `query:"DateFrom"`
	DateTo   string `query:"DateTo"`
}

type UsersUpgratedListReq struct {
	Status   string `query:"Status"`
	Name     string `query:"Name"`
	Email    string `query:"Email"`
	Phone    string `query:"Phone"`
	Role     int    `query:"Role_id"`
	NewRole  int    `query:"NewRole"`
	DateFrom string `query:"DateFrom"`
	DateTo   string `query:"DateTo"`
}
type ServicePendingReq struct {
	Name       string `query:"Name"`
	Email      string `query:"Email"`
	Status     string `query:"Status"`
	Breif      string `query:"Breif"`
	Role_id    int    `query:"Role_id"`
	Service_id int    `query:"Service_id"`
}
type PendingUsersListReq struct {
	Status   string `query:"Status"`
	Name     string `query:"Name"`
	Email    string `query:"Email"`
	Role     int    `query:"Role_id"`
	Phone    string `query:"Phone"`
	DateFrom string `query:"DateFrom"`
	DateTo   string `query:"DateTo"`
}

type ApproveServiceReq struct {
	Msg    string
	FromId int
	ToId   int
}
type ContactListReq struct {
	Status   string `query:"Status"`
	Name     string `query:"Name"`
	Email    string `query:"Email"`
	Phone    string `query:"Phone"`
	DateFrom string `query:"DateFrom"`
	DateTo   string `query:"DateTo"`
}
type ArticlePending struct {
	Id        int
	NameAr    string
	Phone     string
	Email     string
	Title     string
	CreatedAt string
	Status    string
}
type ProjectPending struct {
	Id        int
	UserId    int
	NameAr    string
	Email     string
	Title     string
	Status    string
	Phone     string
	CreatedAt string
}
type ServicePending struct {
	Id          int
	UserId      int
	NameAr      string
	Stat        string
	RoleName    string
	ServiceName string
	Email       string
	Status      string
	Breif       string
	CreatedAt   string
}
