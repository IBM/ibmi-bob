import os
import pytest
from pathlib import Path
from makei.build import BuildEnv
from tests.lib.const import DATA_PATH, MAKEI_PATH


@pytest.fixture
def set_test_directory(request):
    original_cwd = Path.cwd()
    project_name = request.param
    test_dir = Path(f"{DATA_PATH}/build_env/{project_name}").resolve()
    os.chdir(test_dir)
    try:
        yield test_dir
    finally:
        os.chdir(original_cwd)

    

@pytest.mark.parametrize("set_test_directory", ["sample_project1"], indirect=True)
def test_simple_build_env(set_test_directory):
    test_dir = set_test_directory
    try:
        build_env = BuildEnv() 
        assert build_env.src_dir == test_dir
        assert build_env.targets == ["all"]
        assert build_env.make_options == ""
        assert build_env.bob_path == MAKEI_PATH
        assert build_env.bob_makefile == MAKEI_PATH / "src" / "mk" / "Makefile"
        assert os.path.exists(build_env.build_vars_path) == True # -> need to verify contents of the build_vars_path file

        assert build_env.iproj_json_path == test_dir / "iproj.json"
        assert os.path.exists(build_env.iproj_json_path) == True
        assert build_env.ibmi_env_cmds == ""

        assert build_env.success_targets == []
        assert build_env.failed_targets == []
    finally:
        if build_env:
            build_env._post_make()
    