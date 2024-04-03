# essentia-container

An alpine-based [Essentia](https://essentia.upf.edu/) extractor docker container image.

Essentia extractors allow to extract low and high level musical information from audio data (e.g. `average_loudness`, `bpm`, `danceability`, `electronic`).
Some of the extracted fields and detection accurracies are described [here](https://essentia.upf.edu/svm_models/accuracies_v2.1_beta1.html) (for an older version, though).

Differences compared to the [official pre-built binaries](https://essentia.upf.edu/extractors/) and [container](https://github.com/MTG/essentia-docker) (as of 2023):
* The binaries are compiled with [Gaia](https://github.com/MTG/gaia).
* Contains the [SVM models](https://essentia.upf.edu/svm_models/) and a corresponding [example profile](./profile.yaml).
* Uses Alpine Linux base image instead of Debian.
* Multi-arch image that works on both amd64 and arm64 Linux machines.

## Usage

The following example shows how to download an audio file, analyze it using [`essentia_streaming_extractor_music`](https://essentia.upf.edu/streaming_extractor_music.html) and print the result JSON:
```sh
docker run --rm ghcr.io/mgoltzsche/essentia sh -euxc '
  URL=https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3
  wget -qO input.mp3 $URL
  essentia_streaming_extractor_music input.mp3 - /etc/essentia/profile.yaml'
```

For more information, see the [Essentia Extractor documentation](https://essentia.upf.edu/extractors_out_of_box.html#extractors).

## Credits

Essentia is an open-source C++ library with Python bindings for audio analysis and audio-based music information retrieval.
It is released under the Affero GPLv3 license and is also available under proprietary license upon request.
This project is just a redistribution of the library, its extractor CLIs as well as its SVM models as a Linux container image.
[Learn more about the Essentia project](http://essentia.upf.edu)
