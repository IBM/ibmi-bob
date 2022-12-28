"""
required environment variables:
- SPEC_PROJECT_NAME
- SPEC_GITHUB_TOKEN
- SPEC_REPO_OWNER
- SPEC_REPO_NAME
- SPEC_GITHUB_BASE_URL
- SPEC_REPO_SPEC_PATH
"""
import logging
import os
import pathlib
import sys

from github import Github, Repository


def _update_or_create_branch(g: Github, repo: Repository, version: str, project_name: str, main_branch="master"):
    """Create a branch for the spec file or update it if it already exists."""
    branch = f"{project_name}-{version}"
    main_branch_ref = repo.get_branch(main_branch)
    try:
        branch_ref = repo.get_branch(branch=branch)
    except:
        branch_ref = None

    # If the branch exists, update it from the main branch
    if branch_ref:
        ref = repo.get_git_ref(f"heads/{branch}")
        ref.delete()

    repo.create_git_ref(ref=f"refs/heads/{branch}", sha=main_branch_ref.commit.sha)
    print(f"Created branch '{branch}' from '{main_branch}'")


def _update_spec(repo: Repository, spec_content: str, version: str, project_name: str, spec_path: str):
    """Update the spec file in the forked repository."""
    sha = repo.get_contents(spec_path).sha

    repo.update_file(spec_path, f"[{project_name}] Update to {version}", spec_content, sha,
                     branch=f"{project_name}-{version}")


def _create_pull_request(repo: Repository, version: str, project_name: str):
    """Create a pull request for the spec file."""
    pr = repo.create_pull(title=f"[{project_name}] Update to {version}", body="", head=f"{project_name}-{version}",
                          base="master", maintainer_can_modify=True)

    print(f"Created pull request: {pr.html_url}")

    # pr.create_review_request(reviewers=["kadler", "edmund-reinhardt", "esimpson"])


def publish_spec(version: str, spec_file: pathlib.Path, env=os.environ):
    """Publish the spec file to the spec repository."""
    logging.getLogger("urllib3").setLevel(logging.FATAL)
    logging.getLogger("github").setLevel(logging.FATAL)
    
    spec_content = spec_file.read_text()
    g = Github(base_url=env.get("SPEC_GITHUB_BASE_URL"), login_or_token=env.get("SPEC_GITHUB_TOKEN"))

    repo = g.get_repo(f"{env.get('SPEC_REPO_OWNER')}/{env.get('SPEC_REPO_NAME')}")
    spec_path = env.get("SPEC_REPO_SPEC_PATH")
    project_name = env.get("SPEC_PROJECT_NAME")

    _update_or_create_branch(g, repo, version, project_name)
    _update_spec(repo, spec_content, version, project_name, spec_path)
    _create_pull_request(repo, version, project_name)


def main():
    if len(sys.argv) != 3:
        print("Usage: generate_spec.py VERSION SPEC_FILE")
        sys.exit(1)
    version = sys.argv[1]
    spec_file = pathlib.Path(sys.argv[2])

    if not spec_file.exists():
        print(f"Spec file {spec_file} does not exist")
        sys.exit(1)

    publish_spec(version, spec_file)


if __name__ == "__main__":
    main()
