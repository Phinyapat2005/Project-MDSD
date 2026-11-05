import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function GET() {
  try {
    const styles = db.getSavedStyles();
    return NextResponse.json({ success: true, data: styles });
  } catch (error) {
    return NextResponse.json({ success: false, error: "Failed to fetch styles" }, { status: 500 });
  }
}

export async function PATCH(request: Request) {
  try {
    const body = await request.json();
    const { id } = body;
    if (!id) {
      return NextResponse.json({ success: false, error: "Missing id" }, { status: 400 });
    }
    const updated = db.toggleStarStyle(id);
    return NextResponse.json({ success: true, data: updated });
  } catch (error) {
    return NextResponse.json({ success: false, error: "Failed to toggle star" }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const created = db.addSavedStyle(body);
    return NextResponse.json({ success: true, data: created });
  } catch (error) {
    return NextResponse.json({ success: false, error: "Failed to add style" }, { status: 500 });
  }
}
