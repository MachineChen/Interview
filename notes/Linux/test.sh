#!/bin/bash

for i in {1..60}
do
	fileName="每天一个linux命令（${i}）：xxx命令.md"
	if [ ! -f "$fileName" ];then
		touch "$fileName"
	fi
done
