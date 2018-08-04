package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"time"
)

func main() {
	site := flag.String("site", "", "The site to check the health of")
	webhook := flag.String("webhook", "", "The webhook url to hit with the health status")
	interval := flag.Duration("interval", 30*time.Minute, "The interval at which to check the site. Uses go time strings")
	flag.Parse()

	start(*site, *webhook, *interval)
	log.Println("Closed pingy")
}

func start(site, webhook string, interval time.Duration) {
	log.Println("Started pingy")
	for {
		if !isHealthy(site) {
			log.Printf("%s is UN-healthy, sending report", site)
			reportUnhealthy(webhook)
		} else {
			log.Printf("%s is healthy", site)
		}

		time.Sleep(interval)
	}
}

func isHealthy(site string) bool {
	resp, err := http.Head(site)

	if err != nil {
		return false
	}

	defer resp.Body.Close()

	return resp.StatusCode == http.StatusOK
}

func reportUnhealthy(webhook string) {
	report := map[string]string{"text": "Site cannot be reached"}
	json, err := json.Marshal(report)

	if err != nil {
		log.Println("Could not create json body for report")

		return
	}

	log.Printf("Reporting unhealthy site, sending %s to %s", json, webhook)

	resp, err := http.Post(webhook, "application/json", bytes.NewBuffer(json))

	if err != nil {
		log.Printf("Could not make request to webhook")
	}

	log.Printf("+%v", resp)

	defer resp.Body.Close()
}
