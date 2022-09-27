package model

type HomeResponse struct {
	Banner   RichText
	Goals    []RichText
	Roles    []interface{}
	Events   []interface{}
	Users    []interface{}
	Projects []ProjectList
	Features []Feature
}
