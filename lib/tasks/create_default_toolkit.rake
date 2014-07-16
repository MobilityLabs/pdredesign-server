require 'rake'

namespace :db do
  desc "Create all default toolkit objects"
  task :create_default_toolkit => :environment do
    puts '---Starting import of default toolkit'
    toolkit = [
      {
        title: 'I. Strategic Planning',
        description: 'To understand and analyze the current and future state of Professional Development within our district',
        categories: [
          {
            title: 'Current State Analysis',
            subcategories: [
              {
                title: 'Key Information Gathering' ,
                tools: [
                  {title: 'Readiness Assessment', url: '/#/assessments', description: 'The PD Readiness Assessment consists of 28 questions that support team engagement in a candid cross-functional discussion about PD using a common language, and the development of a shared team view to identify the elements to be strengthened or leveraged to support a PD system redesign effort.'},
                  {title: 'Initiative Inventory', url: nil}
                ]
              },
              {
                title: 'Deep Dive Diagnostics' ,
                tools: [
                  {title: 'End User Survey', description: 'This survey is designed to understand the end user’s (i.e. teacher’s) points of view on the current state of Professional Development (PD) as well as their desired future state.', url: nil},
                  {title: 'Technology Diagnostic Product Inventories', description: 'The tool helps districts identify the gaps in their data, delivery and product lines so that purchasing and integration priorities can be established. The language and terminology of the information gathering template and the output of the technology diagnostic are based on the D2S framework.', url: nil},
                  {title: 'Time Diagnostic', url: nil},
                  {title: 'Financial Systems & Budget', url: nil},
                  {title: 'Allocation Diagnostic', url: nil},
                ]
              },
            ]
          },
          {
            title: 'Future State Visioning',
            subcategories: [
              {
                title: 'Strategic Vision Articulation' ,
                tools: [
                  {title: 'Roadmap for first 100 days of PDRedesign', url: nil},
                ]
              },
            ]
          },
        ]
      },
      {
        title: 'II. Implementation Planning',
        description: 'To identify and acquire all of the resources required to fill unmet capabilities',
        categories: [
          {
            title: 'Change Management Planning',
            subcategories: [
             {
                title: 'Internal Hiring'
             },
             {
                title:'Integration/Cohesion Plan',
                tools: [
                  {title: 'IT Deliverables Management Guide', url: nil}
                ]
             },
             {
                title:'Communication Management & Messaging'
             },
             {
                title:'Scheduling'
             },
            ]
          },
          {
            title: 'Procurement Process',
            subcategories: [
              {
                title: 'RFP Development',
                tools: [
                  {title: 'RFP Guidelines', description:'This document provides a list of considerations for the districts to help improve communication among the districts, vendors, and other stakeholders of the PD marketplace.', url: nil},
                  {title: 'Demand-to-Supply Framework', description: 'This framework establishes a view of the processes, technologies, and actors involved in the delivery of PD, centered around core PD use cases and provides a means of classifying products and services that support PD functions.', url: nil},
                ]
              },
              {
                title: 'Initial Vendor Review',
                tools: [
                  {title: 'Vendor Selection Criteria', url: nil},
                  {title: 'Vendor Negotiation Guidelines', url: nil},
                ]
              },
              {
                title: 'Final Vendor Selection',
                tools: [
                  {title: 'Vendor Integration Development', url: nil},
                ]
              },
            ]
          },
        ]
      },
      {
        title: 'III. Implementation Execution',
        description: 'To execute the system change while collection and analyzing feedback',
        categories: [
          {
            title: 'Implementation Pilot',
            subcategories: [
              {
                title:'Labor Management Plan'
              },
              {
                title:'User Feedback'
              },
              {
                title:'Success Metrics'
              },
              {
                title:'Course Adjusting'
              }
            ]

          }
        ]
      }
    ]

    toolkit.each_with_index do |phase, pindex|
      p = ToolPhase.create(title: phase[:title],
                           description: phase[:description],
                           display_order: pindex)
      if phase[:categories].present?
        phase[:categories].each_with_index do |cat, cindex|
          c = p.tool_categories.create(title: cat[:title],
                                      display_order: cindex)
          
          if cat[:subcategories].present?
            cat[:subcategories].each_with_index do |sub, sindex|
              s = c.tool_subcategories.create(title: sub[:title],
                                             display_order: sindex)
              
              if sub[:tools].present?
                sub[:tools].each_with_index do |tool, tindex|
                  t = s.tools.create(title: tool[:title],
                                         description: tool[:description],
                                         tool_category_id: c.id,
                                         url: tool[:url],
                                         display_order: tindex,
                                         is_default: true)
                end
              end

            end
          end

        end
      end

    end

    puts '---Finished import of default toolkit'
    puts "Imported #{ToolPhase.count} Tool Phases"
    puts "Imported #{ToolCategory.count} Tool Categories"
    puts "Imported #{ToolSubcategory.count} Tool Subcategories"
    puts "Imported #{Tool.count} Tools"

  end
end
