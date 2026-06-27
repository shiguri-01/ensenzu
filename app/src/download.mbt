///|
#cfg(target="js")
extern "js" fn download_svg_ffi(filename : String, svg : String) -> Unit =
  #| (filename, svg) => {
  #|   const blob = new Blob([svg], { type: "image/svg+xml;charset=utf-8" });
  #|   const url = URL.createObjectURL(blob);
  #|   const link = document.createElement("a");
  #|   link.href = url;
  #|   link.download = filename;
  #|   document.body.appendChild(link);
  #|   link.click();
  #|   link.remove();
  #|   URL.revokeObjectURL(url);
  #| }

///|
#cfg(target="js")
fn download_svg_cmd(filename : String, svg : String) -> @rabbita.Cmd {
  @cmd.custom_cmd(_ => download_svg_ffi(filename, svg))
}

///|
#cfg(not(target="js"))
fn download_svg_cmd(_filename : String, _svg : String) -> @rabbita.Cmd {
  @rabbita.none
}
