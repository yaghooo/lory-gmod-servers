use serde_derive::Deserialize;
use std::ffi::OsStr;
use std::fs;
use std::path;

#[derive(Deserialize)]
pub struct Configurations {
    pub servers: Vec<Server>,
}

#[derive(Deserialize, Debug)]
pub struct Server {
    pub name: String,
    pub exclude: Option<Vec<String>>,
}

pub fn get_configurations() -> Configurations {
    let configurations_file_res = fs::read_to_string("../servers/.server-scheme.toml");

    if configurations_file_res.is_err() {
        panic!(
            "Could not read configurations file: {:?}",
            configurations_file_res.err()
        );
    } else {
        let configurations_file_content = configurations_file_res.unwrap();
        let configurations = toml::from_str::<Configurations>(&configurations_file_content);

        if configurations.is_err() {
            panic!("Configurations file is invalid: {:?}", configurations.err());
        } else {
            return configurations.unwrap();
        }
    }
}

pub fn get_server_addons_paths(
    configurations: &Configurations,
    server_name: &str,
    is_dev: bool,
) -> Vec<path::PathBuf> {
    let mut addons_arr = Vec::new();

    let server_config = configurations
        .servers
        .iter()
        .find(|sv| *sv.name == *server_name);
    if let Some(server_config) = server_config {
        addons_arr.push(get_addons_from_path("../servers/_shared"));

        if is_dev {
            addons_arr.push(get_addons_from_path("../servers/_debug"));
        }

        let mut server_path = String::from("../servers/");
        server_path.push_str(server_name);
        addons_arr.push(get_addons_from_path(&server_path));

        let mut addons = addons_arr.concat();

        if let Some(exclude_addons) = &server_config.exclude {
            for exclude_addon in exclude_addons {
                let exclude_addon_file = Some(OsStr::new(&exclude_addon));
                let excluded_path = addons
                    .iter()
                    .find(|&path_buf| path_buf.file_name() == exclude_addon_file);

                if let Some(excluded_path) = &excluded_path {
                    let pos = match addons.iter().position(|x| *x == **excluded_path) {
                        Some(x) => x,
                        None => panic!("Unexpected error parsing addon '{}'", exclude_addon),
                    };

                    addons.remove(pos);
                }
            }
        }

        (*addons).to_vec()
    } else {
        panic!("Configurations not found for server {}.", server_name);
    }
}

fn get_addons_from_path(path: &str) -> Vec<path::PathBuf> {
    let dir_paths_res = fs::read_dir(path);
    if dir_paths_res.is_err() {
        panic!(
            "Could not read addon path '{}': {:?}",
            path,
            dir_paths_res.err()
        );
    } else {
        dir_paths_res.unwrap().map(|p| p.unwrap().path()).collect()
    }
}
