package utils

import (
	"crypto/tls"
	"fmt"

	gomail "gopkg.in/mail.v2"
)

func SendEmail(email string, url string) bool {

	m := gomail.NewMessage()

	// Set E-Mail sender
	m.SetHeader("From", "a.dariwsh.dev@gmail.com")

	// Set E-Mail receivers
	m.SetHeader("To", email)

	// Set E-Mail subject
	m.SetHeader("Subject", "استرجاع كلمة مرور  حساب الشاب الريادي")

	// Set E-Mail body. You can set plain text or html with text/html
	link := fmt.Sprintf("<h2>اضغط علي الرابط التالي لاستعادة كلمة المرور</h2><br><a href='%s'>%s</a>", url, url)
	m.SetBody("text/html", link)

	// Settings for SMTP server
	d := gomail.NewDialer("smtp.gmail.com", 587, "a.darwish.dev@gmail.com", "asd@asd@9517532468")

	// This is only needed when SSL/TLS certificate is not valid on server.
	// In production this should be set to false.
	d.TLSConfig = &tls.Config{InsecureSkipVerify: true}

	// Now send E-Mail
	if err := d.DialAndSend(m); err != nil {
		fmt.Println(err)
		panic(err)
	}

	return true
}
