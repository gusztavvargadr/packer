//go:build darwin || linux

package main

import "golang.org/x/sys/unix"

func processCPU() (cpuTime, error) {
	var usage unix.Rusage
	if err := unix.Getrusage(unix.RUSAGE_SELF, &usage); err != nil {
		return cpuTime{}, err
	}
	return cpuTime{
		UserSeconds:   float64(usage.Utime.Sec) + float64(usage.Utime.Usec)/1e6,
		SystemSeconds: float64(usage.Stime.Sec) + float64(usage.Stime.Usec)/1e6,
	}, nil
}
