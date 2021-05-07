# nvidia-docker-ccminer

## How to use

A Dockerized implementation of this [ccminer library](https://github.com/tpruvot/ccminer) running on NVIDIA GPU optimized Ubuntu, ready for deployment using AWS ECS. Built from https://github.com/patrickceg/docker-ccminer to work specifically on latest generation EC2 accelerated compute instances, NVIDIA drivers, and modern Cuda libraries.

**DISCLAIMER: This project is a technical exercise for fun, not a for profit activity. The difficulty of most coins combined with the cost of cloud hosting means mining is not cost effective. You use this entirely at your own risk**

### Installing stuff to make this run

You only need Docker to build the image.

In developing this I never ran `ccminer` on my local computer as I don't have an NVIDIA graphics card. It may be possible to run locally (assuming you can set up the same `Cuda 11.2+`, `nvidia-container-toolkit`, etc environment), but I can't help you there.

### Notes

- Matching the Cuda version with the arch/gencode flags when compiling ccminer is crucial. Have fun researching that...
- Be sure to assign a GPU to your container, explicitly or using the Docker `--gpus all` flag, otherwise you will get ccminer errors and/or zero hashrates

### Donate

If you do happen to find this useful, feel free to make a donation towards the development costs!

BTC: bc1q8lr7wtucvw7ca7g8uq8p633lmy7fpx083kgzct
LTC: LQYpuc1eEhtbHxm7AW6Gfto6v5g412hVvt
DOGE: DCtDgvyRJ3MycSxut5pR7dq9MbY5q5WFH1
XMR: 43iRtEd7ZT4J14orRjHZb39NgZ2jDTkYDbeti5FytwHnKaCxTuGVznHFkE8mHMUN2hZrnmM5wXQyjbro6C3NJm8cR93anuQ
