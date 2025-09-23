from makei.utils import make_include_dirs_absolute, get_compile_targets_from_filenames,decompose_filename


# flake8: noqa: E501

def test_sanity():
    path = '/a/b/.logs/joblog.json'
    parameters = " some stuff at the begginning  aINCDIR ('PARAM1'   'PARAM2' ''PARAM3'' 'PARAM4' )and some stuff after   "
    expected = " some stuff at the begginning  aINCDIR ('/a/b/PARAM1' '/a/b/PARAM2' ''/a/b/PARAM3'' '/a/b/PARAM4')and some stuff after   "
    assert make_include_dirs_absolute(path, parameters) == expected


def test_empty_params():
    path = '/a/b/.logs/joblog.json'
    parameters = " INCDIR (''  '''')"
    expected = " INCDIR ('/a/b/' ''/a/b/'')"
    assert make_include_dirs_absolute(path, parameters) == expected


def test_longer_job_log_path():
    path = '/a/b/cd/efg/hijklmnop/.logs/joblog.json'
    parameters = " INCDIR( 'dir1'  ''dir2'')"
    expected = " INCDIR('/a/b/cd/efg/hijklmnop/dir1' ''/a/b/cd/efg/hijklmnop/dir2'')"
    assert make_include_dirs_absolute(path, parameters) == expected


def test_doesnt_modify_absolute_path():
    path = '/a/b/cd/efg/hijklmnop/.logs/joblog.json'
    parameters = " INCDIR( '/a/b/dir1'  ''dir2'')"
    expected = " INCDIR('/a/b/dir1' ''/a/b/cd/efg/hijklmnop/dir2'')"
    assert make_include_dirs_absolute(path, parameters) == expected


def test_doesnt_modify_absolute_path_with_double_quotes():
    path = '/a/b/cd/efg/hijklmnop/.logs/joblog.json'
    parameters = " INCDIR( ''/a/b/dir1''  ''dir2'')"
    expected = " INCDIR(''/a/b/dir1'' ''/a/b/cd/efg/hijklmnop/dir2'')"
    assert make_include_dirs_absolute(path, parameters) == expected


def test_no_preceding_path_before_logs():
    path = '/.logs/joblog.json'
    parameters = " INCDIR('dir2')"
    expected = " INCDIR('/dir2')"
    assert make_include_dirs_absolute(path, parameters) == expected


def test_joblob_not_found():
    path = '/a/b/cd/efg/hijklmnop/.logs/joblogs.json'
    parameters = " INCDIR( ''/a/b/dir1'' ''dir2'')"
    expected = " INCDIR( ''/a/b/dir1'' ''dir2'')"
    assert make_include_dirs_absolute(path, parameters) == expected

def test_compile_targets_from_filenames():
    expected = ['TEST.DTAARA']
    assert get_compile_targets_from_filenames(['test.DTAARA']) == expected
    expected = ['TEST.FILE']
    assert get_compile_targets_from_filenames(['test.index']) == expected

def test_decompose_filename():
    expected = ('custinfo1', None, 'PFSQL', '')
    assert decompose_filename("custinfo1.pfsql") == expected
    expected = ('CUSTINFO1', None, 'PFSQL', '')
    assert decompose_filename("CUSTINFO1.pfsql") == expected