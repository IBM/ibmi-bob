import json


class Config:
    def __init__(self, config_file):
        self.config_file = config_file
        self._config = self._load_config()

    def _load_config(self):
        with open(self.config_file, 'r', encoding="utf-8") as f:
            return json.load(f)

    def get_config(self):
        return self._config

    def update_config(self, new_config):
        self._config.update(new_config)
        self._save_config()

    def _save_config(self):
        with open(self.config_file, 'w', encoding="utf-8") as f:
            json.dump(self._config, f)
