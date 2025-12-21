1. Add to index.html <head> (Google Fonts)

```
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
```

2. Replace src/index.css (Full Design System)

```
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Core Colors */
    --background: 200 20% 98%;
    --foreground: 207 12% 17%;
    --card: 0 0% 100%;
    --card-foreground: 207 12% 17%;
    --popover: 0 0% 100%;
    --popover-foreground: 207 12% 17%;
    
    /* Primary - Teal */
    --primary: 195 55% 22%;
    --primary-foreground: 0 0% 100%;
    --secondary: 195 20% 94%;
    --secondary-foreground: 195 55% 22%;
    --muted: 195 15% 92%;
    --muted-foreground: 200 15% 45%;
    
    /* Accent - Orange */
    --accent: 22 80% 53%;
    --accent-foreground: 0 0% 100%;
    --destructive: 0 72% 51%;
    --destructive-foreground: 0 0% 100%;
    --border: 195 15% 88%;
    --input: 195 15% 88%;
    --ring: 195 55% 22%;
    --radius: 0.5rem;

    /* 12-Color Chart Palette */
    --chart-1: 210 45% 51%;
    --chart-2: 254 26% 46%;
    --chart-3: 46 87% 57%;
    --chart-4: 349 63% 51%;
    --chart-5: 29 80% 51%;
    --chart-6: 315 30% 60%;
    --chart-7: 49 68% 61%;
    --chart-8: 30 50% 61%;
    --chart-9: 73 68% 61%;
    --chart-10: 97 55% 50%;
    --chart-11: 350 44% 58%;
    --chart-12: 185 60% 64%;
    
    /* Semantic Colors */
    --success: 165 60% 40%;
    --warning: 45 93% 47%;
    --info: 195 80% 45%;

    /* Sidebar - Dark Teal */
    --sidebar-background: 195 55% 20%;
    --sidebar-foreground: 195 15% 95%;
    --sidebar-primary: 22 80% 58%;
    --sidebar-primary-foreground: 0 0% 100%;
    --sidebar-accent: 195 45% 28%;
    --sidebar-accent-foreground: 195 15% 95%;
    --sidebar-border: 195 40% 30%;
    --sidebar-ring: 22 80% 58%;
  }

  .dark {
    --background: 195 40% 8%;
    --foreground: 195 15% 95%;
    --card: 195 35% 12%;
    --card-foreground: 195 15% 95%;
    --popover: 195 35% 12%;
    --popover-foreground: 195 15% 95%;
    --primary: 22 80% 58%;
    --primary-foreground: 0 0% 100%;
    --secondary: 195 30% 18%;
    --secondary-foreground: 195 15% 95%;
    --muted: 195 25% 16%;
    --muted-foreground: 195 15% 55%;
    --accent: 195 30% 22%;
    --accent-foreground: 195 15% 95%;
    --destructive: 0 60% 45%;
    --destructive-foreground: 0 0% 100%;
    --border: 195 25% 20%;
    --input: 195 25% 20%;
    --ring: 22 80% 58%;
    --sidebar-background: 195 45% 10%;
    --sidebar-foreground: 195 15% 95%;
    --sidebar-primary: 22 80% 58%;
    --sidebar-primary-foreground: 0 0% 100%;
    --sidebar-accent: 195 35% 18%;
    --sidebar-accent-foreground: 195 15% 95%;
    --sidebar-border: 195 30% 18%;
    --sidebar-ring: 22 80% 58%;
  }
}

@layer base {
  * { @apply border-border; }
  body {
    @apply bg-background text-foreground antialiased;
    font-family: 'Noto Sans', system-ui, sans-serif;
  }
  h1, h2, h3, h4, h5, h6 {
    font-family: 'Noto Sans', system-ui, sans-serif;
    @apply tracking-tight font-bold;
  }
}

@layer components {
  .stat-card {
    @apply bg-card border border-border p-3 transition-all duration-300 hover:border-primary/20;
    border-radius: 6px;
    box-shadow: 0px 2px 6px rgba(0, 0, 0, 0.08);
  }
  .stat-card:hover { box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.12); }
  .dashboard-grid { @apply grid gap-4; }
  .metric-value { @apply text-2xl font-bold tracking-tight text-foreground; }
  .metric-label { @apply text-xs font-semibold text-muted-foreground uppercase tracking-wider; }
  .trend-positive { @apply text-[hsl(var(--success))] flex items-center gap-1; }
  .trend-negative { @apply text-destructive flex items-center gap-1; }
  .trend-neutral { @apply text-muted-foreground flex items-center gap-1; }
  .page-header { @apply mb-8; }
  .page-title { @apply text-3xl font-bold text-foreground mb-2; }
  .page-subtitle { @apply text-muted-foreground text-lg; }
  .chart-container {
    @apply bg-card border border-border p-4;
    border-radius: 6px;
    box-shadow: 0px 2px 6px rgba(0, 0, 0, 0.08);
  }
  .data-table { @apply w-full text-xs; }
  .data-table th { @apply text-left text-[10px] font-bold uppercase tracking-wider text-muted-foreground pb-2 border-b border-border; }
  .data-table td { @apply py-2 border-b border-border/50; }
}

@layer utilities {
  .animate-fade-in { animation: fadeIn 0.5s ease-out forwards; }
  .animate-slide-up { animation: slideUp 0.5s ease-out forwards; }
  @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
  @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
  .stagger-1 { animation-delay: 0.1s; }
  .stagger-2 { animation-delay: 0.2s; }
  .stagger-3 { animation-delay: 0.3s; }
  .stagger-4 { animation-delay: 0.4s; }
  .stagger-5 { animation-delay: 0.5s; }
  .stagger-6 { animation-delay: 0.6s; }
}
3. Add to tailwind.config.ts (Chart colors)

colors: {
  chart: {
    1: "hsl(var(--chart-1))",
    2: "hsl(var(--chart-2))",
    // ... through 12
  },
  success: "hsl(var(--success))",
  warning: "hsl(var(--warning))",
  info: "hsl(var(--info))",
}
4. Prompt for New Projects
"Use this Looker-style design system with: Noto Sans font, teal primary (#1a5a6e) + orange accent (#e86830), 12-color HSL chart palette, shadcn/ui + Recharts, dark sidebar, .stat-card and .chart-container component classes, fade-in animations with stagger delays. All colors must use CSS variables."

This gives you portable, reusable design system code!






20 Dec
at 15:27
what about the key elements of the design - the left-hand sidebar, the filters, the hamburger menu and Looker logo, the explore and conversational analytics pages, the icons in the top right, the footer etc?



Thought for 9s
I'll examine the key structural components to document the full layout patterns.

I'll examine the key structural components to document the full layout patterns.

Show all
5 tools used
Now let me also get the Header and the main Index page:

Now let me also get the Header and the main Index page:

Show all
3 tools used
Now I have everything. Here's a comprehensive reusable code package you can share with Lovable:

Complete Looker Dashboard Design System
1. index.html — Add to <head>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
2. src/index.css — Full Design System

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 200 20% 98%;
    --foreground: 207 12% 17%;
    --card: 0 0% 100%;
    --card-foreground: 207 12% 17%;
    --popover: 0 0% 100%;
    --popover-foreground: 207 12% 17%;
    --primary: 195 55% 22%;
    --primary-foreground: 0 0% 100%;
    --secondary: 195 20% 94%;
    --secondary-foreground: 195 55% 22%;
    --muted: 195 15% 92%;
    --muted-foreground: 200 15% 45%;
    --accent: 22 80% 53%;
    --accent-foreground: 0 0% 100%;
    --destructive: 0 72% 51%;
    --destructive-foreground: 0 0% 100%;
    --border: 195 15% 88%;
    --input: 195 15% 88%;
    --ring: 195 55% 22%;
    --radius: 0.5rem;

    /* 12-Color Chart Palette */
    --chart-1: 210 45% 51%; --chart-2: 254 26% 46%; --chart-3: 46 87% 57%;
    --chart-4: 349 63% 51%; --chart-5: 29 80% 51%; --chart-6: 315 30% 60%;
    --chart-7: 49 68% 61%; --chart-8: 30 50% 61%; --chart-9: 73 68% 61%;
    --chart-10: 97 55% 50%; --chart-11: 350 44% 58%; --chart-12: 185 60% 64%;
    
    --success: 165 60% 40%; --warning: 45 93% 47%; --info: 195 80% 45%;
    --sidebar-background: 195 55% 20%;
    --sidebar-foreground: 195 15% 95%;
    --sidebar-primary: 22 80% 58%;
    --sidebar-primary-foreground: 0 0% 100%;
    --sidebar-accent: 195 45% 28%;
    --sidebar-accent-foreground: 195 15% 95%;
    --sidebar-border: 195 40% 30%;
    --sidebar-ring: 22 80% 58%;
  }

  .dark {
    --background: 195 40% 8%; --foreground: 195 15% 95%;
    --card: 195 35% 12%; --card-foreground: 195 15% 95%;
    --popover: 195 35% 12%; --popover-foreground: 195 15% 95%;
    --primary: 22 80% 58%; --primary-foreground: 0 0% 100%;
    --secondary: 195 30% 18%; --secondary-foreground: 195 15% 95%;
    --muted: 195 25% 16%; --muted-foreground: 195 15% 55%;
    --accent: 195 30% 22%; --accent-foreground: 195 15% 95%;
    --destructive: 0 60% 45%; --destructive-foreground: 0 0% 100%;
    --border: 195 25% 20%; --input: 195 25% 20%; --ring: 22 80% 58%;
    --sidebar-background: 195 45% 10%; --sidebar-foreground: 195 15% 95%;
    --sidebar-primary: 22 80% 58%; --sidebar-primary-foreground: 0 0% 100%;
    --sidebar-accent: 195 35% 18%; --sidebar-accent-foreground: 195 15% 95%;
    --sidebar-border: 195 30% 18%; --sidebar-ring: 22 80% 58%;
  }
}

@layer base {
  * { @apply border-border; }
  body { @apply bg-background text-foreground antialiased; font-family: 'Noto Sans', system-ui, sans-serif; }
  h1, h2, h3, h4, h5, h6 { font-family: 'Noto Sans', system-ui, sans-serif; @apply tracking-tight font-bold; }
}

@layer components {
  .stat-card { @apply bg-card border border-border p-3 transition-all duration-300 hover:border-primary/20; border-radius: 6px; box-shadow: 0px 2px 6px rgba(0,0,0,0.08); }
  .stat-card:hover { box-shadow: 0px 4px 12px rgba(0,0,0,0.12); }
  .dashboard-grid { @apply grid gap-4; }
  .metric-value { @apply text-2xl font-bold tracking-tight text-foreground; }
  .metric-label { @apply text-xs font-semibold text-muted-foreground uppercase tracking-wider; }
  .trend-positive { @apply text-[hsl(var(--success))] flex items-center gap-1; }
  .trend-negative { @apply text-destructive flex items-center gap-1; }
  .trend-neutral { @apply text-muted-foreground flex items-center gap-1; }
  .chart-container { @apply bg-card border border-border p-4; border-radius: 6px; box-shadow: 0px 2px 6px rgba(0,0,0,0.08); }
  .data-table { @apply w-full text-xs; }
  .data-table th { @apply text-left text-[10px] font-bold uppercase tracking-wider text-muted-foreground pb-2 border-b border-border; }
  .data-table td { @apply py-2 border-b border-border/50; }
}

@layer utilities {
  .animate-fade-in { animation: fadeIn 0.5s ease-out forwards; }
  .animate-slide-up { animation: slideUp 0.5s ease-out forwards; }
  @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
  @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
  .stagger-1 { animation-delay: 0.1s; } .stagger-2 { animation-delay: 0.2s; }
  .stagger-3 { animation-delay: 0.3s; } .stagger-4 { animation-delay: 0.4s; }
}
3. Header Component Pattern

// src/components/dashboard/Header.tsx
import { Menu, Store, MessageCircleQuestion } from 'lucide-react';
import lookerLogo from '@/assets/looker-logo.png'; // Add your logo

export function Header({ onMenuClick }) {
  return (
    <header className="border-b border-border bg-white sticky top-0 z-50">
      <div className="px-4 py-2 flex items-center justify-between">
        {/* Left: Hamburger + Logo */}
        <div className="flex items-center gap-3">
          <button onClick={onMenuClick} className="p-1.5 hover:bg-muted rounded">
            <Menu className="h-5 w-5 text-muted-foreground" />
          </button>
          <img src={lookerLogo} alt="Logo" className="h-7" />
        </div>
        
        {/* Right: Icons + Avatar */}
        <div className="flex items-center gap-2">
          <button className="p-2 hover:bg-muted rounded"><Store className="h-5 w-5 text-muted-foreground" /></button>
          <button className="p-2 hover:bg-muted rounded"><MessageCircleQuestion className="h-5 w-5 text-muted-foreground" /></button>
          <button className="p-2 hover:bg-muted rounded">
            <img src="avatar-url" className="w-8 h-8 rounded-full" />
          </button>
        </div>
      </div>
    </header>
  );
}
```

4. Sidebar Pattern

```

// src/components/dashboard/AppSidebar.tsx
// Key structure:
// - w-52 white sidebar, collapsible
// - "Create" button with Google-rainbow gradient icon
// - Section 1: Explore, Conversations, Develop, Admin (with icons)
// - Divider
// - Section 2: Home, Recently Viewed, Favorites, Boards
// - Active state: bg-blue-50 text-blue-600
// - Uses lucide icons: Compass, MessageSquareText, Code2, Settings, Home, Clock, Star, LayoutGrid

```

5. Filter Pills Pattern

```
// Light blue background (#DAE8FB), chevron dropdown
// Popover with checkboxes and "Clear all"
// Shows "All" when empty, count badge when selected
// Label above each pill in muted text
```

6. Page Layout Pattern

```
// Main layout structure:
<div className="min-h-screen bg-white flex flex-col">
  <Header onMenuClick={toggleSidebar} />
  <div className="flex flex-1">
    <AppSidebar isOpen={sidebarOpen} activeTab={activeTab} onTabChange={setActiveTab} />
    <main className="flex-1 flex flex-col ml-4">
      {/* Breadcrumb + Title bar with Heart, FolderPlus, Refresh, MoreVertical icons */}
      {/* Filters bar */}
      {/* Content area with p-4 */}
    </main>
  </div>
  <footer className="border-t border-border bg-white px-6 py-2 text-xs text-muted-foreground">
    {/* Left: Bold title + disclaimer */}
    {/* Right: Prepared by + date */}
  </footer>
</div>
```

7. Explore Tab Pattern
```
Top bar: Title, row count, timing, "Run" button (blue), Settings icon
Left panel (w-60): Field picker with search, collapsible groups, Dimensions (gray) + Measures (orange)
Main area: Filters bar, visualization type switcher (Table, Bar, Line, Area, Pie icons), data table
Bottom tabs: Data | Results | SQL
```

```
8. Conversational Tab Pattern
Left sidebar (w-56): "New conversation", Recent list with colored letter avatars, "Manage agents", "Trash"
Main chat: Centered input, suggestion buttons, Sparkles icon for AI responses
Right panel (w-72, toggleable): Agent info, "Edit agent" button, data source, owner, timestamps
```

9. Prompt for New Dashboards

```
"Create a Looker-style analytics dashboard with:

Noto Sans font, teal primary (#1a5a6e) + orange accent (#e86830)
White bg, 6px border-radius cards with subtle shadows
Collapsible sidebar (w-52) with Google-style Create button, navigation sections
Sticky header with hamburger menu, logo left, icon buttons + avatar right
Filter bar with light blue (#DAE8FB) dropdown pills
Tab content area with breadcrumb, title bar with favorite/folder/refresh icons
Footer with bold title left, prepared-by right
Charts use Recharts with 12-color HSL palette
Include Explore (field picker + data table) and Conversational (chat interface) pages
All colors via CSS variables, shadcn/ui components, fade-in animations"
```