package config

// Read config.json
import (
	"fmt"

	"github.com/jinzhu/configor"
)

// From struct
type From struct {
	User     string
	Pass     string
	Host     string
	Port     int
	From     string
	Display  string
	Bcc      []string
	Bounce   *string
	Hostname string
}

// Config struct
type Config struct {
	Beanstalk string `default:"127.0.0.1:11300"`
	From      map[string]From
}

// Email struct
type Email struct {
	From        string
	To          []string
	Subject     string
	Html        string
	Text        string
	HtmlEmbed   map[string]string // file.png => base64(bytes)
	Attachments map[string]string // file.png => base64(bytes)
}

var (
	// C contains Config struct
	C Config
)

// Init will read and parse config
func Init(f string) error {

	e := configor.New(&configor.Config{ENVPrefix: "SMTPW"}).Load(&C, f)
	if e != nil {
		return fmt.Errorf("Config error: %s", e)
	}

	return nil
}
