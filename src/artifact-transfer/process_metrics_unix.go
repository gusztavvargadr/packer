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

func freeDiskBytes(path string) (uint64, error) {
	var state unix.Statfs_t
	if err := unix.Statfs(path, &state); err != nil {
		return 0, err
	}
	return uint64(state.Bavail) * uint64(state.Bsize), nil
}
