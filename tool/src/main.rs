use fs_extra;
use symlink;
use std::env;
use std::path;
mod helper;

fn main() {
    let args: Vec<String> = env::args().collect();
    let action = &args.get(1);

    if let Some(action) = action {
        let configurations = helper::get_configurations();

        if *action == "build" {
            let servers = &args[2..];
            build(&configurations, &servers);
        } else if *action == "start" {
            let server = &args[2];
            let server_dir = &args[3];
            start(&configurations, &server, &server_dir);
        }
    } else {
        println!("Action should be specified");
    }
}

fn build(configurations: &helper::Configurations, servers: &[String]) {
    for server in servers {
        let build_path = &format!("../build/{}/", server);
        let build_path_buf = path::Path::new(build_path);

        let create_dir_res = fs_extra::dir::create_all(build_path_buf, true);
        if create_dir_res.is_err() {
            panic!(
                "Failed to create build directory: {:?}",
                create_dir_res.err()
            );
        }

        let copy_options = fs_extra::dir::CopyOptions {
            overwrite: true,
            skip_exist: false,
            buffer_size: 1 << 16,
            copy_inside: false,
            depth: 0,
        };

        let addon_paths = helper::get_server_addons_paths(&configurations, &server, false);
        for addon_path in addon_paths {
            let addon_name = match addon_path.file_name() {
                Some(x) => x,
                None => panic!(
                    "Unexpected error reading addon name in path '{:?}'",
                    addon_path
                ),
            };

            let copy_addon_res = fs_extra::dir::copy(&addon_path, &build_path_buf, &copy_options);

            if copy_addon_res.is_err() {
                panic!(
                    "Failed to install addon '{:?}': {:?}",
                    addon_name,
                    copy_addon_res.err()
                );
            }
        }

        println!("Server '{}' successfully built", server);
    }
}

fn start(configurations: &helper::Configurations, server_name: &str, server_dir: &str) {
    let addon_paths = helper::get_server_addons_paths(&configurations, &server_name, true);
    let server_addons_buf = path::Path::new(server_dir).join("addons");
    
    for addon_path in addon_paths {
        let addon_name = match addon_path.file_name() {
            Some(x) => x,
            None => panic!(
                "Unexpected error reading addon name in path '{:?}'",
                addon_path
            ),
        };

        match symlink::symlink_dir(&addon_path, &server_addons_buf.join(addon_name)) {
            Ok(res) => res,
            Err(err) => panic!("Failed when adding addon in path '{:?}': {}", &addon_path, err)
        }
    }
}
