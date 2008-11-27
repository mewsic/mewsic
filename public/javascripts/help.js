function embedVideo(container, name, length) {
  swfobject.embedSWF("/players/Adelao_Myousica_Video_Player.swf", container, 444, 328, "9.0.0", "/expressInstall.swf", {
    videoURL: "/videos/" + name + ".flv",
    posterURL: "/videos/" + name + ".jpg",
    isLogEnabled: "yes",
    hideFullscreen: "true",
    videoLength: length
  }, { wmode: "transparent" }, { name: "helpVideoPlayer" });
}
