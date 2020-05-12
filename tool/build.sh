cargo build --release --all-features --bins --out-dir ../bin -Z unstable-options
cmd.exe /k "cargo build --release --all-features --bins --out-dir ../bin -Z unstable-options && exit"