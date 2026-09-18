#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

const std::string STATE_FILE = "/tmp/eww_menu_state.json";
const std::string DATA_FILE = "/home/swortech/.config/eww/data/menu_data.json";

json load_data() {
    std::ifstream f(DATA_FILE);
    return json::parse(f);
}

json load_state() {
    try {
        std::ifstream f(STATE_FILE);
        return json::parse(f);
    } catch (...) {
        return {{"root", nullptr}, {"path", json::array()}};
    }
}

void save_state(const json& state) {
    std::ofstream f(STATE_FILE);
    f << state.dump();
}

void update_eww() {
    json data = load_data();
    json state = load_state();

    std::string root = state.value("root", "");
    json path = state.value("path", json::array());

    json columns = json::array();

    if (!root.empty() && data.contains(root)) {
        json curr_items = data[root];
        
        json first_col;
        first_col["level"] = 0;
        first_col["active_id"] = !path.empty() ? path[0] : nullptr;
        first_col["items"] = curr_items;
        columns.push_back(first_col);

        for (size_t idx = 0; idx < path.size(); ++idx) {
            std::string step_id = path[idx];
            json matched = nullptr;

            for (const auto& item : curr_items) {
                if (item.value("id", "") == step_id) {
                    matched = item;
                    break;
                }
            }

            if (!matched.is_null() && matched.contains("children")) {
                curr_items = matched["children"];
                json next_active = (path.size() > idx + 1) ? path[idx + 1] : nullptr;

                json col;
                col["level"] = idx + 1;
                col["active_id"] = next_active;
                col["items"] = curr_items;
                columns.push_back(col);
            } else {
                break;
            }
        }
    }

    std::string cmd = "eww update menu_columns='" + columns.dump() + "'";
    std::system(cmd.c_str());
}

int main(int argc, char* argv[]) {
    if (argc < 2) return 0;
    std::string action = argv[1];

    if (action == "open" && argc >= 3) {
        save_state({{"root", argv[2]}, {"path", json::array()}});
        update_eww();
    } 
    else if (action == "select" && argc >= 4) {
        int level = std::stoi(argv[2]);
        std::string item_id = argv[3];

        json state = load_state();
        json path = state.value("path", json::array());

        json new_path = json::array();
        for (int i = 0; i < level && i < path.size(); ++i) {
            new_path.push_back(path[i]);
        }
        new_path.push_back(item_id);

        state["path"] = new_path;
        save_state(state);
        update_eww();
    } 
    else if (action == "exec" && argc >= 3) {
        std::system("eww update active_menu='' config_icon=images/Config.svg man_icon=images/Man.svg message_icon=images/Message.svg");
        std::string exec_cmd = std::string(argv[2]) + " &";
        std::system(exec_cmd.c_str());
    }

    return 0;
}