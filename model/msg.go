package model

type Msg struct {
	Id        uint
	Msg       string
	Mine      bool
	Name      string
	CreatedAt string
	Seen      string
}
type ChatListResp struct {
	Chats []Inbox `json:"chats"`
	Users []Inbox `json:"users"`
}
type Inbox struct {
	Id   uint
	Name string
	Img  string
}

type MsgReq struct {
	FromId uint
	ToId   int
	Msg    string
}
