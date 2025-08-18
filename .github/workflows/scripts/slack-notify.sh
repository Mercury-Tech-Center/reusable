#!/bin/bash

# Enhanced Slack notification script with team-specific channels and critical alerts

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --webhook)
      WEBHOOK_URL="$2"
      shift 2
      ;;
    --channel)
      CHANNEL="$2"
      shift 2
      ;;
    --event)
      EVENT="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --regions)
      REGIONS="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --cluster)
      CLUSTER="$2"
      shift 2
      ;;
    --team)
      TEAM="$2"
      shift 2
      ;;
    --workflow_url)
      WORKFLOW_URL="$2"
      shift 2
      ;;
    --level)
      LEVEL="$2"
      shift 2
      ;;
    --critical_tag)
      CRITICAL_TAG="$2"
      shift 2
      ;;
    --summary)
      SUMMARY="$2"
      shift 2
      ;;
    --error_details)
      ERROR_DETAILS="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Function to send Slack message with blocks
send_slack_blocks() {
  local blocks="$1"
  
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"blocks\":$blocks}" \
    "$WEBHOOK_URL"
}

# Function to determine team-specific channel
get_team_channel() {
  local team="$1"
  local default_channel="$2"
  
  case $team in
    "Crush Aviator"|"crush-aviator")
      echo "#crush-aviator-deployments"
      ;;
    "Mercury Tech"|"mercury-tech")
      echo "#mercury-deployments"
      ;;
    "Aviator Games"|"aviator-games")
      echo "#aviator-deployments"
      ;;
    *)
      echo "$default_channel"
      ;;
  esac
}

# Get team-specific channel
TEAM_CHANNEL=$(get_team_channel "$TEAM" "$CHANNEL")

# Different notification types with enhanced formatting
case $EVENT in
  "deployment_started")
    blocks='[
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "�� Deployment Started"
        }
      },
      {
        "type": "section",
        "fields": [
          {
            "type": "mrkdwn",
            "text": "*Repository:*\n`'$REPO'`"
          },
          {
            "type": "mrkdwn",
            "text": "*Branch:*\n`'$BRANCH'`"
          },
          {
            "type": "mrkdwn",
            "text": "*Team:*\n'$TEAM'"
          },
          {
            "type": "mrkdwn",
            "text": "*Channel:*\n'$TEAM_CHANNEL'"
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Regions:* `'$REGIONS'`"
        }
      }
    ]'
    ;;
    
  "auto_deployment_success")
    blocks='[
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "✅ *Auto-Deployment Success*\n• Region: `'$REGION'`\n• Cluster: `'$CLUSTER'`\n• Status: Deployed automatically"
        }
      }
    ]'
    ;;
    
  "approval_required")
    blocks='[
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "⏳ Manual Approval Required"
        }
      },
      {
        "type": "section",
        "fields": [
          {
            "type": "mrkdwn",
            "text": "*Region:*\n`'$REGION'`"
          },
          {
            "type": "mrkdwn",
            "text": "*Team:*\n'$TEAM'"
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Deployment is waiting for manual approval in '$REGION'"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "Review & Approve"
            },
            "url": "'$WORKFLOW_URL'",
            "style": "primary"
          }
        ]
      }
    ]'
    ;;
    
  "deployment_success")
    blocks='[
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "✅ *Deployment Success*\n• Region: `'$REGION'`\n• Cluster: `'$CLUSTER'`\n• Status: Successfully deployed"
        }
      }
    ]'
    ;;
    
  "deployment_summary")
    blocks='[
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "�� Deployment Summary"
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "'$SUMMARY'"
        }
      }
    ]'
    ;;
esac

# Send the notification
send_slack_blocks "$blocks"