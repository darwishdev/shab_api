package model

type ContactSendReq struct {
	Name    string
	Email   string
	Subject string
	Phone   string
	Breif   string
}

type ContactPending struct {
	Id        int
	UserId    int
	Name      string
	Email     string
	Status    string
	Phone     string
	Subject   string
	Msg       string
	CreatedAt string
}
