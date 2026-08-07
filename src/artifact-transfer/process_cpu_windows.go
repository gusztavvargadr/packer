//go:build windows

package main

import "golang.org/x/sys/windows"

func processCPU() (cpuTime, error) {
	var creationTime windows.Filetime
	var exitTime windows.Filetime
	var kernelTime windows.Filetime
	var userTime windows.Filetime
	if err := windows.GetProcessTimes(windows.CurrentProcess(), &creationTime, &exitTime, &kernelTime, &userTime); err != nil {
		return cpuTime{}, err
	}
	return cpuTime{
		UserSeconds:   filetimeSeconds(userTime),
		SystemSeconds: filetimeSeconds(kernelTime),
	}, nil
}

func freeDiskBytes(path string) (uint64, error) {
	directory, err := windows.UTF16PtrFromString(path)
	if err != nil {
		return 0, err
	}
	var available uint64
	if err := windows.GetDiskFreeSpaceEx(directory, &available, nil, nil); err != nil {
		return 0, err
	}
	return available, nil
}

func filetimeSeconds(value windows.Filetime) float64 {
	ticks := uint64(value.HighDateTime)<<32 | uint64(value.LowDateTime)
	return float64(ticks) / 1e7
}
