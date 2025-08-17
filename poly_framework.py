"""
Poly-AI Framework for Adaptive GitHub Workflow Automation
"""
import os
import requests
import numpy as np
from github import Github

def rank_tools(tools, weights):
    """
    Rank tools based on weighted metrics using linear algebra.
    
    Args:
        tools (list): List of tools with metrics
        weights (list): Weights for each metric
        
    Returns:
        list: Sorted list of tools with scores
    """
    matrix = np.array([t['metrics'] for t in tools])
    scores = matrix @ np.array(weights)
    return sorted(zip(tools, scores), key=lambda x: x[1], reverse=True)

def fetch_github_tools(query="automation", per_page=8):
    """
    Fetch top GitHub tools based on stars and other metrics.
    
    Args:
        query (str): Search query for GitHub repositories
        per_page (int): Number of repositories to fetch
        
    Returns:
        list: List of tools with their metrics
    """
    # Initialize GitHub client
    g = Github(os.getenv("GITHUB_TOKEN"))
    
    # Search for repositories
    repos = g.search_repositories(query=query, sort="stars", order="desc")
    
    results = []
    for repo in repos[:per_page]:
        results.append({
            "name": repo.full_name,
            "metrics": [
                repo.stargazers_count,
                repo.forks_count,
                int("actions" in repo.topics),
                int("ai" in repo.topics)
            ],
            "url": repo.html_url
        })
    return results

def pick_workflow_type(env):
    """
    Pick workflow type based on environment variables.
    
    Args:
        env (dict): Environment variables
        
    Returns:
        str: Workflow file name
    """
    if env.get("ENTERPRISE") == "true":
        return "ai_enterprise.yml"
    elif env.get("OPEN_SOURCE") == "true":
        return "os_workflow.yml"
    return "default_workflow.yml"

def fetch_tool_recommendations_perplexity(query):
    """
    Fetch tool recommendations using Perplexity API.
    
    Args:
        query (str): Query for tool recommendations
        
    Returns:
        dict: JSON response from Perplexity API
    """
    # Note: This is a placeholder implementation
    # In a real implementation, you would need to use the actual Perplexity API
    r = requests.get(f"https://api.perplexity.ai/recommend/tools?q={query}")
    return r.json() if r.status_code == 200 else []

if __name__ == "__main__":
    # Define weights for ranking tools
    weights = [0.4, 0.3, 0.2, 0.1]
    
    # Fetch GitHub tools
    tools = fetch_github_tools()
    
    # Rank tools
    ranked = rank_tools(tools, weights)
    
    # Print ranked tools
    print("Top GitHub Automation Tools (Polymorphic Ranking):")
    for i, (tool, score) in enumerate(ranked, 1):
        print(f"{i}. {tool['name']} ({tool['url']}) — Score: {score:.2f}")
    
    # Pick workflow type
    selected_workflow = pick_workflow_type(os.environ)
    print(f"Deploying workflow: {selected_workflow}")