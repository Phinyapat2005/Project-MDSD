import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function GET() {
  try {
    const measurements = db.getMeasurements();
    return NextResponse.json({ success: true, data: measurements });
  } catch (error) {
    return NextResponse.json({ success: false, error: "Failed to fetch measurements" }, { status: 500 });
  }
}

export async function PUT(request: Request) {
  try {
    const body = await request.json();
    const updated = db.updateMeasurements({
      height: Number(body.height),
      weight: Number(body.weight),
      waist: Number(body.waist),
      chest: Number(body.chest),
      hips: Number(body.hips),
    });
    return NextResponse.json({ success: true, data: updated });
  } catch (error) {
    return NextResponse.json({ success: false, error: "Failed to update measurements" }, { status: 500 });
  }
}
