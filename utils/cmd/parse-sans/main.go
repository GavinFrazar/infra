package main

import (
	"flag"
	"fmt"
	"net"
	"os"
	"strings"
)

func main() {
	var sansArg string
	flag.StringVar(&sansArg, "sans", "", "comma separated list of subjectAltNames.")
	flag.Parse()

	if sansArg == "" {
		flag.Usage()
		fmt.Fprintln(flag.CommandLine.Output(), "at least one subjectAltName is required.")
		os.Exit(1)
	}
	sans := strings.Split(sansArg, ",")

	var out []string
	for _, s := range sans {
		if ip := net.ParseIP(s); ip != nil {
			out = append(out, fmt.Sprintf("IP:%s", s))
		} else {
			out = append(out, fmt.Sprintf("DNS:%s", s))
		}
	}
	fmt.Println(strings.Join(out, ","))
}
