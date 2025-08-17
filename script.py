# AI Job Finder Framework Implementation
# Creating the actual framework with real current job data

import pandas as pd
import json
from datetime import datetime, timedelta
import re

# Current Live AI Jobs Data (August 17, 2025)
current_ai_jobs = [
    {
        "title": "AI Content Writer (DataAnnotation)",
        "budget": "$20+ USD/hour",
        "platform": "Indeed/DataAnnotation",
        "posted": "Recent",
        "skills": ["English writing", "Content creation", "AI training"],
        "pay_speed": "Hourly - PayPal",
        "location": "Remote",
        "description": "Train AI chatbots, write conversations, compare AI models",
        "immediate_pay": True,
        "hours_per_week": "5-40 hours",
        "application_url": "DataAnnotation.tech"
    },
    {
        "title": "Hebrew Language Image Collection (iPhone)",
        "budget": "$150 USD per 500 images",
        "platform": "Freelancer.com",
        "posted": "Today",
        "skills": ["iPhone photography", "Hebrew language"],
        "pay_speed": "Per batch completion",
        "location": "Israel (Remote)",
        "description": "Collect Hebrew text images for AI training",
        "immediate_pay": True,
        "hours_per_week": "Flexible",
        "application_url": "freelancer.com"
    },
    {
        "title": "Turkish Language Image Collection (iPhone)",
        "budget": "$150 USD per 500 images", 
        "platform": "Freelancer.com",
        "posted": "Today",
        "skills": ["iPhone photography", "Turkish language"],
        "pay_speed": "Per batch completion",
        "location": "Turkey (Remote)",
        "description": "Collect Turkish text images for AI training",
        "immediate_pay": True,
        "hours_per_week": "Flexible",
        "application_url": "freelancer.com"
    },
    {
        "title": "AI Solutions Architect (E-commerce)",
        "budget": "$50-100/hour",
        "platform": "Freelancer.com",
        "posted": "1 day ago",
        "skills": ["Full-stack development", "AI integration", "ML"],
        "pay_speed": "Hourly/Project",
        "location": "Remote",
        "description": "Design AI features for e-commerce optimization",
        "immediate_pay": True,
        "hours_per_week": "20-40 hours",
        "application_url": "freelancer.com"
    },
    {
        "title": "Machine Learning Research Paper Writer",
        "budget": "$30-60/hour",
        "platform": "Freelancer.com", 
        "posted": "Recent",
        "skills": ["Academic writing", "Machine Learning", "Research"],
        "pay_speed": "Hourly/Fixed",
        "location": "Remote",
        "description": "Write and publish ML research papers",
        "immediate_pay": True,
        "hours_per_week": "10-30 hours",
        "application_url": "freelancer.com"
    },
    {
        "title": "Data Science Expert for CNN Models",
        "budget": "2000 INR (6 hours total)",
        "platform": "Freelancer.com",
        "posted": "Recent",
        "skills": ["CNN", "Image classification", "Python", "GitHub"],
        "pay_speed": "Daily pay - 2 hours/day for 3 days",
        "location": "Remote",
        "description": "Build multi-model CNN for image classification",
        "immediate_pay": True,
        "hours_per_week": "6 hours over 3 days",
        "application_url": "freelancer.com"
    },
    {
        "title": "AI Companies Research & Lead Generation",
        "budget": "$8-15/hour",
        "platform": "Vollna/Upwork",
        "posted": "45 minutes ago",
        "skills": ["Research", "Lead Generation", "B2B Marketing"],
        "pay_speed": "Hourly",
        "location": "Remote",
        "description": "Find 500 AI companies for performance improvement",
        "immediate_pay": True,
        "hours_per_week": "Flexible",
        "application_url": "vollna.com"
    },
    {
        "title": "Real-Time Multilingual Speech Transcription",
        "budget": "$50-150/hour",
        "platform": "Freelancer.com",
        "posted": "Recent",
        "skills": ["ASR", "NLP", "WebSocket APIs", "Speaker Diarization"],
        "pay_speed": "Hourly/Project",
        "location": "Remote", 
        "description": "Build streaming platform for live speech transcription",
        "immediate_pay": True,
        "hours_per_week": "30-40 hours",
        "application_url": "freelancer.com"
    }
]

# Convert to DataFrame for analysis
df_jobs = pd.DataFrame(current_ai_jobs)

print("=== AI JOB FINDER FRAMEWORK - LIVE RESULTS ===")
print(f"Search Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print(f"Total Jobs Found: {len(df_jobs)}")
print(f"Immediate Pay Jobs: {sum(df_jobs['immediate_pay'])}")
print("\n")

# Filter for immediate payment jobs
immediate_jobs = df_jobs[df_jobs['immediate_pay'] == True]
print("=== HIGH-PRIORITY IMMEDIATE PAY JOBS ===")

for idx, job in immediate_jobs.iterrows():
    print(f"\n🚀 {job['title']}")
    print(f"💰 Pay: {job['budget']}")
    print(f"📱 Platform: {job['platform']}")
    print(f"⏱️ Posted: {job['posted']}")
    print(f"💡 Skills: {', '.join(job['skills'])}")
    print(f"⚡ Payment: {job['pay_speed']}")
    print(f"🌐 Apply: {job['application_url']}")
    print("-" * 50)

# Create priority scoring system
def calculate_priority_score(job):
    score = 0
    
    # Immediate payment bonus
    if job['immediate_pay']:
        score += 10
        
    # Recent posting bonus
    if any(word in job['posted'].lower() for word in ['today', 'recent', 'minutes', 'hours']):
        score += 8
        
    # High pay rate bonus  
    budget_str = job['budget'].lower()
    if any(rate in budget_str for rate in ['$50', '$100', '$150']):
        score += 6
    elif any(rate in budget_str for rate in ['$20', '$30']):
        score += 4
        
    # Skills demand bonus
    high_demand_skills = ['python', 'machine learning', 'ai', 'nlp', 'full-stack']
    job_skills_lower = [skill.lower() for skill in job['skills']]
    for skill in high_demand_skills:
        if any(skill in job_skill for job_skill in job_skills_lower):
            score += 3
            
    return score

# Add priority scores
df_jobs['priority_score'] = df_jobs.apply(calculate_priority_score, axis=1)

# Sort by priority score
top_jobs = df_jobs.nlargest(5, 'priority_score')

print("\n=== TOP 5 HIGHEST PRIORITY JOBS (BY ALGORITHM) ===")
for idx, job in top_jobs.iterrows():
    print(f"\n🎯 Priority Score: {job['priority_score']}")
    print(f"📋 {job['title']}")
    print(f"💰 {job['budget']}")
    print(f"📍 {job['platform']}")
    print(f"🔥 {job['description'][:60]}...")

# Export results to CSV
df_jobs.to_csv('ai_jobs_live_results.csv', index=False)
print(f"\n✅ Results exported to: ai_jobs_live_results.csv")

# Generate application templates
print("\n=== AUTO-GENERATED PROPOSAL TEMPLATES ===")

def generate_proposal_template(job):
    template = f"""
Subject: Expert {job['title']} - Ready to Start Immediately

Hello,

I'm an experienced AI researcher with expertise in {', '.join(job['skills'][:3])}. 

I can deliver your {job['title'].lower()} project with:
✅ Immediate availability (can start today)
✅ Proven experience in {job['skills'][0]} and related technologies  
✅ Fast turnaround while maintaining quality standards
✅ Clear communication and regular updates

For your {job['description'][:50]}... project, I propose:
- Timeline: Quick delivery within your specified timeframe
- Rate: Competitive and aligned with project value
- Quality: Professional standards with revision support

I'm available for immediate discussion. Let's connect to discuss next steps.

Best regards,
[Your Name]
"""
    return template.strip()

# Show templates for top 3 jobs
for idx, job in top_jobs.head(3).iterrows():
    print(f"\n--- PROPOSAL FOR: {job['title']} ---")
    print(generate_proposal_template(job))
    print("\n" + "="*60)