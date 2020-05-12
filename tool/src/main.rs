use fs_extra;
use std::env;
use std::path;
mod helper;

fn main() {
    println!("Loading command");

    let args: Vec<String> = env::args().collect();
    let action = &args.get(1);

    if let Some(action) = action {
        let configurations = helper::get_configurations();

        if *action == "build" {
            let servers = &args[2..];
            for server in servers {
                build_server(&configurations, server.to_string());
                println!("Server '{}' successfully built", server);
            }
        } else {
            println!("Action {} not found", action);
        }
    } else {
        println!("Action should be specified");
    }
}

fn build_server(configurations: &helper::Configurations, server: String) {
    let build_path = path::Path::new("../build").join(&server);

    let create_dir_res = fs_extra::dir::create_all(&build_path, true);
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

        let copy_addon_res = fs_extra::dir::copy(&addon_path, &build_path, &copy_options);

        if copy_addon_res.is_err() {
            panic!(
                "Failed to install addon '{:?}': {:?}",
                addon_name,
                copy_addon_res.err()
            );
        }
    }
}
